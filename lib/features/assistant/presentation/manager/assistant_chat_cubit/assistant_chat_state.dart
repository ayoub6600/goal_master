part of 'assistant_chat_cubit.dart';

class AssistantChatState extends Equatable {
  final List<AssistantMessage> messages;
  final String? avatarUrl;
  final Map<String, String?> avatarStates;
  final String assistantName;
  final String assistantShortName;
  final bool loading;
  final bool sending;
  final String? error;

  const AssistantChatState({
    this.messages = const [],
    this.avatarUrl,
    this.avatarStates = const {},
    this.assistantName = 'كابتن أيوب',
    this.assistantShortName = 'كابتن أيوب',
    this.loading = false,
    this.sending = false,
    this.error,
  });

  /// Picks the avatar for a given message's state, falling back to the
  /// default avatar (or the legacy single [avatarUrl]) when that state
  /// has no dedicated image uploaded.
  String? avatarFor(String assistantState) {
    return avatarStates[assistantState] ?? avatarStates['default'] ?? avatarUrl;
  }

  AssistantChatState copyWith({
    List<AssistantMessage>? messages,
    String? avatarUrl,
    Map<String, String?>? avatarStates,
    String? assistantName,
    String? assistantShortName,
    bool? loading,
    bool? sending,
    String? error,
  }) {
    return AssistantChatState(
      messages: messages ?? this.messages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarStates: avatarStates ?? this.avatarStates,
      assistantName: assistantName ?? this.assistantName,
      assistantShortName: assistantShortName ?? this.assistantShortName,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        avatarUrl,
        avatarStates,
        assistantName,
        assistantShortName,
        loading,
        sending,
        error,
      ];
}
