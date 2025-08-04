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
        queryParameters: {'page': page},
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
