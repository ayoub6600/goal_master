import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/support/support_repo.dart';

void main() {
  test('reads a support message payload', () {
    final m = SupportMessage.fromJson({
      'id': 7,
      'from_admin': false,
      'is_system': false,
      'body': ' مرحبا ',
      'image_url': null,
      'deleted': false,
      'reply_to': {'id': 3, 'preview': 'سؤال سابق', 'from_admin': true},
      'client_uuid': 'abc',
      'read': true,
      'created_at': '2026-11-17T10:00:00+02:00',
    });
    expect(m.id, 7);
    expect(m.mine, isTrue);
    expect(m.body, 'مرحبا');
    expect(m.replyPreview, 'سؤال سابق');
    expect(m.read, isTrue);
  });

  test('admin and system messages are not the person\'s own', () {
    expect(SupportMessage.fromJson({'id': 1, 'from_admin': true}).mine, isFalse);
    expect(SupportMessage.fromJson({'id': 2, 'is_system': true}).mine, isFalse);
  });

  test('a deleted message has no body', () {
    final m = SupportMessage.fromJson({'id': 4, 'deleted': true, 'body': null});
    expect(m.deleted, isTrue);
    expect(m.body, isNull);
  });

  test('client ids are unique v4 uuids', () {
    final ids = List.generate(200, (_) => SupportRepo.newClientUuid());
    expect(ids.toSet().length, 200);
    for (final id in ids) {
      expect(
          RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
              .hasMatch(id),
          isTrue);
    }
  });

  test('reads a voice message, an edit, an automatic reply and reactions', () {
    final m = SupportMessage.fromJson({
      'id': 9,
      'type': 'voice',
      'from_admin': true,
      'is_auto_reply': true,
      'edited': true,
      'audio_url': 'https://example.test/v?signature=x',
      'audio_duration_ms': 3800,
      'audio_expired': false,
      'reactions': [
        {'emoji': '❤️', 'from_admin': false},
        {'emoji': '👍', 'from_admin': true},
      ],
      'created_at': '2026-11-17T10:00:00+02:00',
    });
    expect(m.isVoice, isTrue);
    expect(m.audioDurationMs, 3800);
    expect(m.isAutoReply, isTrue);
    expect(m.edited, isTrue);
    expect(m.reactions.length, 2);
    expect(m.myReaction, '❤️');
  });

  test('a deleted copy drops its content and reactions', () {
    final m = SupportMessage.fromJson({
      'id': 3,
      'type': 'voice',
      'audio_url': 'https://example.test/v',
      'reactions': [
        {'emoji': '👍', 'from_admin': true}
      ],
    }).copyWith(deleted: true);
    expect(m.deleted, isTrue);
    expect(m.isVoice, isFalse);
    expect(m.audioUrl, isNull);
    expect(m.reactions, isEmpty);
  });
}

