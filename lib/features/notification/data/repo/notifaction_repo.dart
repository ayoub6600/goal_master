import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';

abstract class NotificationRepo {
  Future<Either<Failure, NotificationResponse>> getNotifications(int page);

  Future<Either<Failure, String>> markNotificationAsRead(String notificationId);
  Future<Either<Failure, String>> markAllNotificationsAsRead();
}
