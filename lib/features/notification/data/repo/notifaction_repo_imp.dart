import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/data/repo/notifaction_repo.dart';

class NotificationRepoImp extends NotificationRepo {
  final ApiConsumer consumer;

  NotificationRepoImp(this.consumer);

  @override
  Future<Either<Failure, NotificationResponse>> getNotifications(int page) {
    return consumer.handleRequest(
      () => consumer.get(
        EndPoints.notification,
        // Excludes this person's Manager-side notifications (e.g. new
        // bookings at a venue they manage) from the Customer App's list —
        // the backend otherwise returns every notification ever sent to
        // this users.id, Customer and Manager alike, since both apps share
        // one identity.
        queryParameters: {'page': page, 'app_domain': 'customer'},
      ),
      (data) => NotificationResponse.fromJson(data),
    );
  }

  @override
  Future<Either<Failure, String>> markAllNotificationsAsRead() {
    return consumer.handleRequest(
      () => consumer.post(
        EndPoints.markAllNotificationsAsRead,
      ),
      (data) => data['message'],
    );
  }

  @override
  Future<Either<Failure, String>> markNotificationAsRead(
      String notificationId) {
    return consumer.handleRequest(
      () => consumer.post(
        EndPoints.markNotificationAsRead(notificationId),
        queryParameters: {'notification_id': notificationId},
      ),
      (data) => data['message'],
    );
  }
}
