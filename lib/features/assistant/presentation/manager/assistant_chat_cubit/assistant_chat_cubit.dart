import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo.dart';

part 'assistant_chat_state.dart';

class AssistantChatCubit extends Cubit<AssistantChatState> {
  AssistantChatCubit(this.assistantRepo) : super(const AssistantChatState());

  final AssistantRepo assistantRepo;

  Future<void> loadHistory() async {
    emit(state.copyWith(loading: true, error: null));
    final result = await assistantRepo.getHistory();
    result.fold(
      (failure) =>
          emit(state.copyWith(loading: false, error: failure.errMessage)),
      (conversation) => emit(state.copyWith(
        loading: false,
        messages: conversation.messages,
        avatarUrl: conversation.avatarUrl,
        avatarStates: conversation.avatarStates,
        assistantName: conversation.assistantName,
        assistantShortName: conversation.assistantShortName,
      )),
    );
  }

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(sending: true, error: null));
    final result = await assistantRepo.sendText(text.trim());
    result.fold(
      (failure) =>
          emit(state.copyWith(sending: false, error: failure.errMessage)),
      (conversation) => emit(state.copyWith(
        sending: false,
        messages: conversation.messages,
        avatarUrl: conversation.avatarUrl,
        avatarStates: conversation.avatarStates,
        assistantName: conversation.assistantName,
        assistantShortName: conversation.assistantShortName,
      )),
    );
  }

  Future<void> sendAction(String action, Map<String, dynamic> payload) async {
    emit(state.copyWith(sending: true, error: null));
    final result = await assistantRepo.sendAction(action, payload);
    result.fold(
      (failure) =>
          emit(state.copyWith(sending: false, error: failure.errMessage)),
      (conversation) => emit(state.copyWith(
        sending: false,
        messages: conversation.messages,
        avatarUrl: conversation.avatarUrl,
        avatarStates: conversation.avatarStates,
        assistantName: conversation.assistantName,
        assistantShortName: conversation.assistantShortName,
      )),
    );
  }
}
