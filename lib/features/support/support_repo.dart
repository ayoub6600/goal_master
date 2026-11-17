import 'dart:io';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/dio_consumer.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/services/service_locator.dart';

/// One message in the customer-service thread.
class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.fromAdmin,
    required this.isSystem,
    required this.deleted,
    required this.read,
    required this.createdAt,
    this.body,
    this.imageUrl,
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
  final String? body;
  final String? imageUrl;
  final String? replyPreview;
  final String? clientUuid;

  bool get mine => !fromAdmin && !isSystem;

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
      body: _str(json['body']),
      imageUrl: _str(json['image_url']),
      replyPreview: reply is Map ? _str(reply['preview']) : null,
      clientUuid: _str(json['client_uuid']),
    );
  }
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
  Future<Either<Failure, (List<SupportMessage>, bool)>> messages(
      {int? beforeId}) {
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
        // Opening the thread reads it.
        unread.value = 0;
        return (list, data['handoff'] == true);
      },
    );
  }

  Future<Either<Failure, SupportMessage>> send({
    String? body,
    File? image,
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
          if (replyToId != null) 'reply_to_id': replyToId.toString(),
          'client_uuid': clientUuid,
        }),
      ),
      (json) => SupportMessage.fromJson(
          (json['data'] as Map).cast<String, dynamic>()),
    );
  }

  Future<Either<Failure, bool>> delete(int id) {
    return _api.handleRequest(
      () => _api.delete('$basePath/chat/messages/$id'),
      (_) => true,
    );
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
