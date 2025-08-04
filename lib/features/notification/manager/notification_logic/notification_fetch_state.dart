import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class NotificationFetchState {}

class NotificationInitialState extends NotificationFetchState {}

class NotificationLoadingState extends NotificationFetchState {}

class NotificationLoadSuccessState extends NotificationFetchState {
  final PagingController<int, NotificationItem> pagingController;

  NotificationLoadSuccessState({required this.pagingController});
}

class NotificationLoadFailureState extends NotificationFetchState {
  final String message;

  NotificationLoadFailureState({required this.message});
}

class NotificationMarkingAllAsReadState extends NotificationFetchState {}

class NotificationMarkAllAsReadSuccessState extends NotificationFetchState {
  final String message;

  NotificationMarkAllAsReadSuccessState({required this.message});
}

class NotificationMarkAllAsReadFailureState extends NotificationFetchState {
  final String message;

  NotificationMarkAllAsReadFailureState({required this.message});
}
