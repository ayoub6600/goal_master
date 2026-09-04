import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';

abstract class AssistantRepo {
  /// [markRead] clears the unread badge. Only the chat screen passes true:
  /// the floating bubble fetches the same history just for the avatar, and
  /// that must not count as having read anything.
  Future<Either<Failure, AssistantConversationResponse>> getHistory({
    bool markRead = false,
  });

  /// How many Captain messages are waiting, for the badge on the bubble.
  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, AssistantConversationResponse>> sendText(String text);

  Future<Either<Failure, AssistantConversationResponse>> sendAction(
      String action, Map<String, dynamic> payload);
}
