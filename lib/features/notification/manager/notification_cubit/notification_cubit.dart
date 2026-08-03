import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/utils/notification_socket_service.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;
  final void Function(NotificationItem)? onVisualNotification;

  late final PagingController<int, NotificationItem> _pagingController;
  late final NotificationSocketService _socketService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isDisposed = false;
  String? _lastNotificationId;

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
      onNotificationReceived: _onNotificationReceived,
    );

    _fetchPage(1);
    emit(NotificationLoadSuccess(
        pagingController: _pagingController, unreadCount: unreadCount));
    emit(NotificationUnreadUpdated(unreadCount));
  }

  late Timer _pollingTimer;

  void startSocket() {
    if (_isDisposed) return;
    _socketService.initialize();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      print('[\u23F1\uFE0F Polling] التحقق من وجود إشعارات جديدة...');
      _checkForNewNotification();
    });
  }

  Future<void> _checkForNewNotification() async {
    if (_isDisposed) return;

    final result = await notificationRepo.getNotifications(1);
    result.fold(
      (failure) => {},
      (response) {
        final latest = response.data.data.firstOrNull;
        if (latest != null && latest.id != _lastNotificationId) {
          _lastNotificationId = latest.id;
          _onNotificationReceived(latest);
        }
      },
    );
  }

  Future<void> _onNotificationReceived(NotificationItem notification) async {
    if (_isDisposed) return;

    print('[🔔 إشعار جديد]: ${notification.data.message}');

    try {
      await _audioPlayer.play(
        AssetSource('sound/new-notification-09-352705.mp3'),
      );
    } catch (e) {
      print('[NotificationCubit] فشل تشغيل صوت الإشعار: $e');
    }

    onVisualNotification?.call(notification);

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
    _socketService.dispose();
    _pagingController.dispose();
    _pollingTimer.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
