import 'package:flutter/widgets.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/utils/notification_socket_service.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState>
    with WidgetsBindingObserver {
  final NotificationRepo notificationRepo;
  final void Function(NotificationItem)? onVisualNotification;

  late final PagingController<int, NotificationItem> _pagingController;
  late final NotificationSocketService _socketService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<RemoteMessage>? _fcmForegroundSubscription;

  bool _isDisposed = false;

  /// The newest notification already shown to this customer.
  ///
  /// Read from storage rather than starting empty: an in-memory watermark is
  /// null on every fresh login, and the loop below then treats the entire
  /// first page as unseen — replaying every old notification, with its sound,
  /// each time somebody signs in.
  String? _lastNotificationId =
      SharedPreferenceUtil.getString(PrefKey.lastSeenNotificationId).isEmpty
          ? null
          : SharedPreferenceUtil.getString(PrefKey.lastSeenNotificationId);

  PagingController<int, NotificationItem> get pagingController =>
      _pagingController;

  NotificationCubit({
    required this.notificationRepo,
    required int userId,
    this.onVisualNotification,
  }) : super(NotificationInitial()) {
    _pagingController =
        PagingController<int, NotificationItem>(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);

    _socketService = NotificationSocketService(
      userId: userId,
      // The socket only wakes the app. Re-fetch the stored notification so
      // its assistant type/avatar are available before anything is shown.
      onNotificationReceived: (_) => _checkForNewNotification(),
    );

    _fetchPage(1);
    emit(NotificationLoadSuccess(
        pagingController: _pagingController, unreadCount: unreadCount));
    emit(NotificationUnreadUpdated(unreadCount));
  }

  Timer? _pollingTimer;

  /// How often to fall back to asking over HTTP.
  ///
  /// Was five seconds, unconditionally, for as long as the app was alive —
  /// roughly 720 requests an hour per customer, almost all of them answering
  /// "nothing new", and most of them while the socket was already delivering
  /// the same events. Thirty seconds is ample for a fallback that only runs
  /// when the live channel is down.
  static const Duration _pollInterval = Duration(seconds: 30);

  void startSocket() {
    if (_isDisposed) return;

    _socketService.initialize();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  /// A foreground FCM message never auto-displays the way a
  /// background/terminated one does — the OS hands it to app code instead,
  /// which is exactly why nothing was visibly happening for it before this.
  /// Deliberately just another wake-up, exactly like the socket's own
  /// `onNotificationReceived` above: the actual notification always comes
  /// from re-fetching the authoritative database record, never from the
  /// push payload itself, so the existing watermark
  /// (`_lastNotificationId`/`_rememberLatest`) is what prevents a socket
  /// wake-up and an FCM wake-up for the same backend event from showing it
  /// twice — no separate id-matching needed here.
  void listenForForegroundFcm() {
    if (_isDisposed) return;
    _fcmForegroundSubscription =
        FirebaseMessaging.onMessage.listen((_) => _checkForNewNotification());
  }

  void _startPolling() {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(_pollInterval, (_) {
      if (_isDisposed) return;

      // The socket is the primary channel. Polling exists for the times it
      // is not connected, so asking while it IS connected is pure waste.
      if (_socketService.isConnected) return;

      _checkForNewNotification();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Nothing is worth polling for while the customer cannot see the screen.
  ///
  /// A backgrounded app kept the timer running, so it went on querying the
  /// server — and draining the battery — for notifications nobody was there
  /// to read. Anything that arrives meanwhile is still delivered by push, and
  /// is caught up on the next resume.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    if (state == AppLifecycleState.resumed) {
      _checkForNewNotification();
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  Future<void> _checkForNewNotification() async {
    if (_isDisposed) return;

    final result = await notificationRepo.getNotifications(1);
    result.fold(
      (failure) => {},
      (response) {
        final notifications = response.data.data;
        if (notifications.isEmpty) return;

        final previousLatestId = _lastNotificationId;
        final unseen = <NotificationItem>[];

        // The API returns newest first. A booking refusal can create both the
        // Captain offer and a regular cancellation notice in the same second;
        // process every unseen item rather than losing the Captain offer when
        // the regular notice happens to be first.
        for (final notification in notifications) {
          if (notification.id == previousLatestId) break;
          unseen.add(notification);
        }

        final isFirstEverCheck = previousLatestId == null;

        _rememberLatest(notifications.first.id);

        if (unseen.isEmpty) return;

        // Nothing has been shown to this device before, so there is no way to
        // tell what the customer has already read. Take the current state as
        // the starting point and stay quiet — announcing a backlog on first
        // launch is noise, not news.
        if (isFirstEverCheck) return;

        final hasCaptainOffer = unseen.any(
          (notification) => notification.data.type == 'captain_rejection_offer',
        );

        // Restore chronological order for the notification list. When an
        // offer is present, it is the only foreground visual: the normal
        // cancellation record remains in the list without masking Captain.
        for (final notification in unseen.reversed) {
          final showVisual = !hasCaptainOffer ||
              notification.data.type == 'captain_rejection_offer';
          _onNotificationReceived(notification, showVisual: showVisual);
        }
      },
    );
  }

  /// Moves the watermark, in memory and on disk.
  void _rememberLatest(String id) {
    _lastNotificationId = id;
    SharedPreferenceUtil.putString(PrefKey.lastSeenNotificationId, id);
  }

  Future<void> _onNotificationReceived(
    NotificationItem notification, {
    bool showVisual = true,
  }) async {
    if (_isDisposed) return;

    if (showVisual) {
      print('[🔔 إشعار جديد]: ${notification.data.message}');

      try {
        await _audioPlayer.play(
          AssetSource('sound/new-notification-09-352705.mp3'),
        );
      } catch (e) {
        print('[NotificationCubit] فشل تشغيل صوت الإشعار: $e');
      }

      onVisualNotification?.call(notification);
    }

    final current = _pagingController.itemList ?? [];

    if (!current.any((item) => item.id == notification.id)) {
      final updatedList = [notification, ...current];
      _pagingController.itemList = updatedList;

      final newUnreadCount = updatedList
          .where((item) => item.readAt == null || item.readAt!.isEmpty)
          .length;

      emit(NotificationLoadSuccess(
        pagingController: _pagingController,
        unreadCount: newUnreadCount,
      ));

      print('[✅] Updated unreadCount: $newUnreadCount');
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    if (_isDisposed) return;

    try {
      final result = await notificationRepo.getNotifications(pageKey);
      if (_isDisposed) return;

      result.fold(
        (failure) {
          _pagingController.error = failure.errMessage;
          emit(NotificationLoadFailure(message: failure.errMessage));
        },
        (response) {
          final notifications = response.data.data;
          if (pageKey == 1 && notifications.isNotEmpty) {
            _lastNotificationId ??= notifications.first.id;
          }

          final isLastPage = pageKey >= response.data.lastPage;
          if (isLastPage) {
            _pagingController.appendLastPage(notifications);
          } else {
            _pagingController.appendPage(notifications, pageKey + 1);
          }

          emit(NotificationLoadSuccess(
              pagingController: _pagingController, unreadCount: unreadCount));
          emit(NotificationUnreadUpdated(unreadCount));
        },
      );
    } catch (error) {
      _pagingController.error = error.toString();
      emit(NotificationLoadFailure(message: error.toString()));
    }
  }

  void refresh() {
    if (_isDisposed) return;
    _pagingController.refresh();
    emit(NotificationLoading());
  }

  Future<void> markAllAsRead() async {
    if (_isDisposed) return;

    final currentItems = _pagingController.itemList;
    if (!hasUnreadNotifications()) return;

    emit(NotificationMarkingAllAsRead());

    if (currentItems != null) {
      final updated = currentItems
          .map(
              (item) => item.copyWith(readAt: DateTime.now().toIso8601String()))
          .toList();
      _pagingController.itemList = updated;
    }

    final result = await notificationRepo.markAllNotificationsAsRead();

    if (_isDisposed) return;

    result.fold(
      (failure) =>
          emit(NotificationMarkAllAsReadFailure(message: failure.errMessage)),
      (message) => emit(NotificationMarkAllAsReadSuccess(message: message)),
    );
  }

  int get unreadCount {
    return _pagingController.itemList
            ?.where((item) => item.readAt == null || item.readAt!.isEmpty)
            .length ??
        0;
  }

  bool hasUnreadNotifications() => unreadCount > 0;
  Future<void> markAsRead(String notificationId) async {
    if (_isDisposed) return;

    final currentItems = _pagingController.itemList;
    if (currentItems == null) return;

    final index = currentItems.indexWhere((item) => item.id == notificationId);
    if (index == -1) return;

    final updatedItem =
        currentItems[index].copyWith(readAt: DateTime.now().toIso8601String());
    currentItems[index] = updatedItem;
    _pagingController.itemList = List.from(currentItems);

    final result =
        await notificationRepo.markNotificationAsRead(notificationId);

    result.fold(
      (failure) => print('[❌] فشل تعيين الإشعار كمقروء: ${failure.errMessage}'),
      (message) => print('[✅] الإشعار $notificationId تم تحديثه بنجاح'),
    );

    emit(NotificationUnreadUpdated(unreadCount));
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _socketService.dispose();
    _fcmForegroundSubscription?.cancel();
    _pagingController.dispose();
    _stopPolling();
    _audioPlayer.dispose();
    return super.close();
  }
}
