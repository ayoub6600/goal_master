import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';

abstract class AssistantRepo {
  Future<Either<Failure, AssistantConversationResponse>> getHistory();

  Future<Either<Failure, AssistantConversationResponse>> sendText(String text);

  Future<Either<Failure, AssistantConversationResponse>> sendAction(
      String action, Map<String, dynamic> payload);
}
