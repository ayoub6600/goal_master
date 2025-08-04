part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoadSuccess extends NotificationState {
  final PagingController<int, NotificationItem> pagingController;
  final int unreadCount;

  const NotificationLoadSuccess({
    required this.pagingController,
    required this.unreadCount,
  });

  @override
  List<Object?> get props =>
      [unreadCount]; // لا تضف pagingController لأنه غير قابل للمقارنة
}

class NotificationLoadFailure extends NotificationState {
  final String message;
  const NotificationLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationMarkingAllAsRead extends NotificationState {}

class NotificationUnreadUpdated extends NotificationState {
  final int unreadCount;
  const NotificationUnreadUpdated(this.unreadCount);

  @override
  List<Object?> get props => [unreadCount];
}

class NotificationMarkAllAsReadSuccess extends NotificationState {
  final String message;
  const NotificationMarkAllAsReadSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationMarkAllAsReadFailure extends NotificationState {
  final String message;
  const NotificationMarkAllAsReadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationRealtimeReceived extends NotificationState {
  final NotificationItem notification;
  const NotificationRealtimeReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}
