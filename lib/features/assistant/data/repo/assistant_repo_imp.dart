import 'package:dartz/dartz.dart';
import 'package:goal_master/features/location/data/active_location_snapshot.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo.dart';

class AssistantRepoImp extends AssistantRepo {
  final ApiConsumer apiConsumer;

  AssistantRepoImp(this.apiConsumer);

  /// The customer's Active Location.
  ///
  /// Read live on every request, so «نبي ملعب قريب» means near wherever the
  /// customer has just said they are — the captain follows a location change
  /// immediately, with no assistant-specific storage of its own to go stale.
  Map<String, dynamic> get _locationParams =>
      ActiveLocationSnapshot.requestParams;

  @override
  Future<Either<Failure, AssistantConversationResponse>> getHistory({
    bool markRead = false,
  }) {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(
        EndPoints.assistantHistory,
        queryParameters: {
          ..._locationParams,
          if (markRead) 'mark_read': 1,
        },
      ),
      (data) => AssistantConversationResponse.fromJson(
          Map<String, dynamic>.from(data['data'])),
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.assistantUnread),
      (data) => (data['data']?['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<Either<Failure, AssistantConversationResponse>> sendText(String text) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.assistantMessage,
        isFormData: false,
        data: {'text': text, ..._locationParams},
      ),
      (data) => AssistantConversationResponse.fromJson(
          Map<String, dynamic>.from(data['data'])),
    );
  }

  @override
  Future<Either<Failure, AssistantConversationResponse>> sendAction(
      String action, Map<String, dynamic> payload) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.assistantMessage,
        isFormData: false,
        data: {'action': action, 'payload': payload, ..._locationParams},
      ),
      (data) => AssistantConversationResponse.fromJson(
          Map<String, dynamic>.from(data['data'])),
    );
  }
}
