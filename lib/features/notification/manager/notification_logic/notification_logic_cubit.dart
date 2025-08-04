import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_fetch_state.dart';
import 'package:goal_master/utils/notification_socket_service.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationFetchCubit extends Cubit<NotificationFetchState> {
  final NotificationRepo notificationRepo;
  late final PagingController<int, NotificationItem> _pagingController;
  late final NotificationSocketService _socketService;

  bool _isDisposed = false;

  PagingController<int, NotificationItem> get pagingController =>
      _pagingController;

  NotificationFetchCubit({
    required this.notificationRepo,
    required int userId,
  }) : super(NotificationInitialState()) {
    _pagingController =
        PagingController<int, NotificationItem>(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);

    _socketService = NotificationSocketService(
      userId: userId,
      onNotificationReceived: (notification) {
        if (_isDisposed) return;
        final current = _pagingController.itemList ?? [];
        _pagingController.itemList = [notification, ...current];
        emit(NotificationLoadSuccessState(pagingController: _pagingController));
      },
    );

    _socketService.initialize();
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
          _pagingController.error = failure.errMessage;
          emit(NotificationLoadFailureState(message: failure.errMessage));
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
      emit(NotificationLoadFailureState(message: error.toString()));
    }
  }

  void refresh() {
    if (_isDisposed) return;
    _pagingController.refresh();
    emit(NotificationLoadingState());
  }

  Future<void> markAllAsRead() async {
    if (_isDisposed) return;

    final currentItems = _pagingController.itemList;
    if (!hasUnreadNotifications()) return;

    emit(NotificationMarkingAllAsReadState());

    if (currentItems != null) {
      final updatedItems = currentItems
          .map(
            (item) => item.copyWith(
              readAt: DateTime.now().toIso8601String(),
            ),
          )
          .toList();
      _pagingController.itemList = updatedItems;
    }

    final result = await notificationRepo.markAllNotificationsAsRead();

    if (_isDisposed) return;

    result.fold(
      (failure) {
        emit(
            NotificationMarkAllAsReadFailureState(message: failure.errMessage));
      },
      (message) {
        emit(NotificationMarkAllAsReadSuccessState(message: message));
      },
    );
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
    _socketService.dispose();
    _pagingController.dispose();
    return super.close();
  }
}
