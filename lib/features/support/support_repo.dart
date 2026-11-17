import 'dart:io';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/dio_consumer.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/services/service_locator.dart';

/// One emoji on a message; the admins react as one side.
class SupportReaction {
  const SupportReaction(this.emoji, this.fromAdmin);
  final String emoji;
  final bool fromAdmin;
}

/// One message in the customer-service thread.
class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.fromAdmin,
    required this.isSystem,
    required this.deleted,
    required this.read,
    required this.createdAt,
    this.type = 'text',
    this.body,
    this.imageUrl,
    this.audioUrl,
    this.audioDurationMs = 0,
    this.audioExpired = false,
    this.edited = false,
    this.isAutoReply = false,
    this.reactions = const [],
    this.replyPreview,
    this.clientUuid,
  });

  final int id;
  final bool fromAdmin;
  final bool isSystem;
  final bool deleted;

  /// For the person's own messages: an admin has read it (✓✓).
  final bool read;
  final DateTime createdAt;

  /// text | image | voice
  final String type;
  final String? body;
  final String? imageUrl;
  final String? audioUrl;
  final int audioDurationMs;
  final bool audioExpired;
  final bool edited;
  final bool isAutoReply;
  final List<SupportReaction> reactions;
  final String? replyPreview;
  final String? clientUuid;

  bool get mine => !fromAdmin && !isSystem;
  bool get isVoice => type == 'voice';

  /// The person's own emoji on this message, if any.
  String? get myReaction {
    for (final r in reactions) {
      if (!r.fromAdmin) return r.emoji;
    }
    return null;
  }

  SupportMessage copyWith({List<SupportReaction>? reactions, bool? deleted}) =>
      SupportMessage(
        id: id,
        fromAdmin: fromAdmin,
        isSystem: isSystem,
        deleted: deleted ?? this.deleted,
        read: read,
        createdAt: createdAt,
        type: (deleted ?? false) ? 'text' : type,
        body: (deleted ?? false) ? null : body,
        imageUrl: (deleted ?? false) ? null : imageUrl,
        audioUrl: (deleted ?? false) ? null : audioUrl,
        audioDurationMs: audioDurationMs,
        audioExpired: audioExpired,
        edited: edited,
        isAutoReply: isAutoReply,
        reactions: (deleted ?? false) ? const [] : (reactions ?? this.reactions),
        replyPreview: replyPreview,
        clientUuid: clientUuid,
      );

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    final reply = json['reply_to'];
    return SupportMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fromAdmin: json['from_admin'] == true || json['from_admin'] == 1,
      isSystem: json['is_system'] == true || json['is_system'] == 1,
      deleted: json['deleted'] == true,
      read: json['read'] == true,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}')?.toLocal() ??
          DateTime.now(),
      type: _str(json['type']) ?? 'text',
      body: _str(json['body']),
      imageUrl: _str(json['image_url']),
      audioUrl: _str(json['audio_url']),
      audioDurationMs: (json['audio_duration_ms'] as num?)?.toInt() ?? 0,
      audioExpired: json['audio_expired'] == true,
      edited: json['edited'] == true,
      isAutoReply: json['is_auto_reply'] == true,
      reactions: reactionsFrom(json['reactions']),
      replyPreview: reply is Map ? _str(reply['preview']) : null,
      clientUuid: _str(json['client_uuid']),
    );
  }

  static List<SupportReaction> reactionsFrom(dynamic list) => (list is List
          ? list
          : const [])
      .whereType<Map>()
      .map((r) => SupportReaction('${r['emoji'] ?? ''}',
          r['from_admin'] == true || r['from_admin'] == 1))
      .where((r) => r.emoji.isNotEmpty)
      .toList();
}

/// A page of the thread, and what the server allows in it.
class SupportThread {
  const SupportThread({
    required this.messages,
    required this.handoff,
    this.reactions = defaultReactions,
    this.voiceMaxSeconds = 120,
    this.adminTyping = false,
  });

  static const defaultReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  final List<SupportMessage> messages;
  final bool handoff;
  final List<String> reactions;
  final int voiceMaxSeconds;

  /// An admin is writing an answer right now.
  final bool adminTyping;
}

String? _str(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Customer service chat with the Goal Master team. [basePath] is
/// `user/support` in the customer app and `manager/support` in the venue
/// manager app.
class SupportRepo {
  SupportRepo({this.basePath = 'user/support'});

  final String basePath;

  /// Unread replies, for the badge on the «خدمة العملاء» entry.
  static final ValueNotifier<int> unread = ValueNotifier<int>(0);

  DioConsumer get _api => getIt<DioConsumer>();

  /// The latest page, or the page before [beforeId] (scrolling back).
  Future<Either<Failure, SupportThread>> messages({int? beforeId}) {
    return _api.handleRequest(
      () => _api.get(
        '$basePath/chat',
        queryParameters: beforeId != null ? {'before_id': beforeId} : null,
      ),
      (json) {
        final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const {};
        final list = (data['messages'] as List? ?? const [])
            .whereType<Map>()
            .map((m) => SupportMessage.fromJson(m.cast<String, dynamic>()))
            .toList();
        final allowed = (data['reactions'] as List?)
            ?.map((e) => '$e')
            .where((e) => e.isNotEmpty)
            .toList();
        // Opening the thread reads it.
        unread.value = 0;
        return SupportThread(
          messages: list,
          handoff: data['handoff'] == true,
          reactions: (allowed == null || allowed.isEmpty)
              ? SupportThread.defaultReactions
              : allowed,
          voiceMaxSeconds: (data['voice_max_seconds'] as num?)?.toInt() ?? 120,
          adminTyping: data['admin_typing'] == true,
        );
      },
    );
  }

  Future<Either<Failure, SupportMessage>> send({
    String? body,
    File? image,
    File? audio,
    int? audioMs,
    int? replyToId,
    required String clientUuid,
  }) {
    return _api.handleRequest(
      () async => _api.post(
        '$basePath/chat/messages',
        data: FormData.fromMap({
          if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
          if (image != null)
            'image': await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          if (audio != null)
            'audio': await MultipartFile.fromFile(
              audio.path,
              filename: 'voice.m4a',
              contentType: DioMediaType('audio', 'mp4'),
            ),
          if (audioMs != null) 'duration_ms': audioMs.toString(),
          if (replyToId != null) 'reply_to_id': replyToId.toString(),
          'client_uuid': clientUuid,
        }),
      ),
      (json) => SupportMessage.fromJson(
          (json['data'] as Map).cast<String, dynamic>()),
    );
  }

  Future<Either<Failure, SupportMessage>> edit(int id, String body) {
    return _api.handleRequest(
      // JSON, not multipart: PHP does not read a multipart PATCH body.
      () => _api.patch('$basePath/chat/messages/$id',
          data: {'body': body}, isFormData: false),
      (json) => SupportMessage.fromJson(
          (json['data'] as Map).cast<String, dynamic>()),
    );
  }

  /// [emoji] null takes one's reaction back. Returns the message's reactions.
  Future<Either<Failure, List<SupportReaction>>> react(int id, String? emoji) {
    return _api.handleRequest(
      () => _api.post('$basePath/chat/messages/$id/react',
          data: {'emoji': emoji}),
      (json) => SupportMessage.reactionsFrom(
          (json['data'] as Map?)?['reactions']),
    );
  }

  Future<Either<Failure, bool>> delete(int id) {
    return _api.handleRequest(
      () => _api.delete('$basePath/chat/messages/$id'),
      (_) => true,
    );
  }

  /// «I am writing» — sent every few seconds while the person types.
  /// Returns whether an admin is writing too (false on failure).
  Future<bool> typing() async {
    final result = await _api.handleRequest(
      () => _api.post('$basePath/chat/typing'),
      (json) => (json['data'] as Map?)?['admin_typing'] == true,
    );
    return result.fold((_) => false, (v) => v);
  }

  /// Refreshes [unread]; failures leave it as it was.
  Future<void> refreshUnread() async {
    final result = await _api.handleRequest(
      () => _api.get('$basePath/chat/unread'),
      (json) => ((json['data'] as Map?)?['unread'] as num?)?.toInt() ?? 0,
    );
    result.fold((_) {}, (n) => unread.value = n);
  }

  /// A random v4-style id so a retried send is not stored twice.
  static String newClientUuid() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
