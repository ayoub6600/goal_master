import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo.dart';

class AssistantRepoImp extends AssistantRepo {
  final ApiConsumer apiConsumer;

  AssistantRepoImp(this.apiConsumer);

  /// The customer's last-known GPS position, already persisted by
  /// LayoutCubit whenever the home screen resolves it — reused here so the
  /// captain persona can follow the customer's zone without the assistant
  /// feature needing its own location plumbing.
  Map<String, dynamic> get _locationParams {
    final hasLat = SharedPreferenceUtil.haveKey(PrefKey.savedLat) == true;
    final hasLng = SharedPreferenceUtil.haveKey(PrefKey.savedLng) == true;
    if (!hasLat || !hasLng) {
      return const {};
    }
    return {
      'lat': SharedPreferenceUtil.getDouble(PrefKey.savedLat),
      'lng': SharedPreferenceUtil.getDouble(PrefKey.savedLng),
    };
  }

  @override
  Future<Either<Failure, AssistantConversationResponse>> getHistory() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(
        EndPoints.assistantHistory,
        queryParameters: _locationParams,
      ),
      (data) => AssistantConversationResponse.fromJson(
          Map<String, dynamic>.from(data['data'])),
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
