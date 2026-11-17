import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_fetch_state.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// The notifications screen's list.
///
/// It no longer opens its own live socket: `IO.io` returns the same cached
/// socket for the same address, so this screen's socket WAS the app-wide
/// one — and closing the screen disposed it (listeners cleared,
/// disconnected), leaving the app on 30-second polling until restart. New
/// notifications reach the app through the app-wide [NotificationCubit];
/// this screen shows the list and pull-to-refresh brings it up to date.
class NotificationFetchCubit extends Cubit<NotificationFetchState> {
  final NotificationRepo notificationRepo;
  late final PagingController<int, NotificationItem> _pagingController;

  bool _isDisposed = false;

  PagingController<int, NotificationItem> get pagingController =>
      _pagingController;

  NotificationFetchCubit({
    required this.notificationRepo,
    // Kept for the call sites; the live channel is the app-wide cubit's.
    int? userId,
  }) : super(NotificationInitialState()) {
    _pagingController =
        PagingController<int, NotificationItem>(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
    emit(NotificationLoadSuccessState(pagingController: _pagingController));
  }

  Future<void> _fetchPage(int pageKey) async {
    if (_isDisposed) return;

    try {
      final result = await notificationRepo.getNotifications(pageKey);
      if (_isDisposed) return;

      result.fold(
        (failure) {
          if (_isDisposed) return;
          // The paged list shows its own error with a retry; the screen
          // stays on the list (a full-screen failure state hid the retry of
          // later pages and stuck after the first error).
          _pagingController.error = failure.errMessage;
        },
        (response) {
          if (_isDisposed) return;
          final notifications = response.data.data;
          final isLastPage = pageKey >= response.data.lastPage;

          if (isLastPage) {
            _pagingController.appendLastPage(notifications);
          } else {
            _pagingController.appendPage(notifications, pageKey + 1);
          }
          emit(NotificationLoadSuccessState(
              pagingController: _pagingController));
        },
      );
    } catch (error) {
      if (_isDisposed) return;
      _pagingController.error = error.toString();
    }
  }

  /// Reloads from the first page. The list stays mounted (it shows its own
  /// first-page loading): emitting a separate «loading» state replaced the
  /// list with a spinner, so nothing asked for the first page again and the
  /// screen stayed on that spinner forever — what happened after
  /// «mark all read» and on pull-to-refresh.
  Future<void> refresh() async {
    if (_isDisposed) return;
    _pagingController.refresh();
    emit(NotificationLoadSuccessState(pagingController: _pagingController));
  }

  Future<void> markAllAsRead() async {
    if (_isDisposed) return;
    if (!hasUnreadNotifications()) return;

    final before = _pagingController.itemList;
    emit(NotificationMarkingAllAsReadState());
    _setAllRead();

    final result = await notificationRepo.markAllNotificationsAsRead();
    if (_isDisposed) return;

    result.fold(
      (failure) {
        if (before != null) _pagingController.itemList = before;
        emit(NotificationMarkAllAsReadFailureState(message: failure.errMessage));
        emit(NotificationLoadSuccessState(pagingController: _pagingController));
      },
      (message) {
        emit(NotificationMarkAllAsReadSuccessState(message: message));
        emit(NotificationLoadSuccessState(pagingController: _pagingController));
      },
    );
  }

  /// One notification opened: shown as read here at once (the server call
  /// is made by the app-wide cubit, which also lowers the bell badge).
  void markReadLocally(String id) {
    if (_isDisposed) return;
    final items = _pagingController.itemList;
    if (items == null) return;
    final i = items.indexWhere((n) => n.id == id);
    if (i == -1 || (items[i].readAt != null && items[i].readAt!.isNotEmpty)) {
      return;
    }
    final updated = List<NotificationItem>.from(items);
    updated[i] = items[i].copyWith(readAt: DateTime.now().toIso8601String());
    _pagingController.itemList = updated;
    emit(NotificationLoadSuccessState(pagingController: _pagingController));
  }

  void _setAllRead() {
    final items = _pagingController.itemList;
    if (items == null) return;
    final now = DateTime.now().toIso8601String();
    _pagingController.itemList = items
        .map((item) => (item.readAt == null || item.readAt!.isEmpty)
            ? item.copyWith(readAt: now)
            : item)
        .toList();
  }

  int get unreadCount {
    final items = _pagingController.itemList;
    return items
            ?.where((item) => item.readAt == null || item.readAt!.isEmpty)
            .length ??
        0;
  }

  bool hasUnreadNotifications() => unreadCount > 0;

  @override
  Future<void> close() {
    _isDisposed = true;
    _pagingController.dispose();
    return super.close();
  }
}
