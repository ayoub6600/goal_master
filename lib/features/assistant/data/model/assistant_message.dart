class QuickReply {
  final String label;
  final String action;
  final Map<String, dynamic> payload;
  final String? imageUrl;
  final String? subtitle;

  QuickReply({
    required this.label,
    required this.action,
    required this.payload,
    this.imageUrl,
    this.subtitle,
  });

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      label: json['label']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'])
          : {},
      imageUrl: json['image_url']?.toString(),
      subtitle: json['subtitle']?.toString(),
    );
  }
}

class AssistantMessage {
  final String sender; // 'customer' or 'captain'
  final String body;
  final List<QuickReply>? quickReplies;
  final String? voiceUrl;
  final String? createdAt;
  final String assistantState;

  AssistantMessage({
    required this.sender,
    required this.body,
    this.quickReplies,
    this.voiceUrl,
    this.createdAt,
    this.assistantState = 'default',
  });

  bool get isCaptain => sender == 'captain';

  factory AssistantMessage.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    List<QuickReply>? replies;
    String? voiceUrl;
    String assistantState = 'default';
    if (payload is Map) {
      if (payload['quick_replies'] is List) {
        replies = (payload['quick_replies'] as List)
            .map((e) => QuickReply.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      voiceUrl = payload['voice_url']?.toString();
      assistantState = payload['assistant_state']?.toString() ?? 'default';
    }
    return AssistantMessage(
      sender: json['sender']?.toString() ?? 'captain',
      body: json['body']?.toString() ?? '',
      quickReplies: replies,
      voiceUrl: voiceUrl,
      createdAt: json['created_at']?.toString(),
      assistantState: assistantState,
    );
  }
}

class AssistantConversationResponse {
  final int conversationId;
  final String flowState;
  final String? avatarUrl;
  final Map<String, String?> avatarStates;
  final List<AssistantMessage> messages;
  final String assistantName;
  final String assistantShortName;

  AssistantConversationResponse({
    required this.conversationId,
    required this.flowState,
    required this.avatarUrl,
    this.avatarStates = const {},
    required this.messages,
    this.assistantName = 'كابتن أيوب',
    this.assistantShortName = 'كابتن أيوب',
  });

  /// Picks the right avatar image for a message's [assistantState],
  /// falling back to the default avatar (or the legacy single [avatarUrl])
  /// when that state has no image of its own.
  String? avatarFor(String assistantState) {
    return avatarStates[assistantState] ?? avatarStates['default'] ?? avatarUrl;
  }

  factory AssistantConversationResponse.fromJson(Map<String, dynamic> json) {
    final rawStates = json['avatar_states'];
    return AssistantConversationResponse(
      conversationId: json['conversation_id'] is int
          ? json['conversation_id']
          : int.tryParse('${json['conversation_id']}') ?? 0,
      flowState: json['flow_state']?.toString() ?? 'idle',
      avatarUrl: json['avatar_url']?.toString(),
      avatarStates: rawStates is Map
          ? rawStates.map((k, v) => MapEntry(k.toString(), v?.toString()))
          : const {},
      assistantName: json['assistant_name']?.toString() ?? 'كابتن أيوب',
      assistantShortName:
          json['assistant_short_name']?.toString() ?? 'كابتن أيوب',
      messages: (json['messages'] as List? ?? [])
          .map((e) => AssistantMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
