import 'dart:async';
import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:goal_master/core/components/preference_utility.dart';

/// Keeps the captain's face on screen from the first frame.
///
/// The avatar URLs only arrive with the assistant history, so on every launch
/// the floating bubble showed a placeholder until that request (and then the
/// image download) finished. The last known URLs are kept on the device, and
/// every state's image is fetched into the disk cache once — so the next
/// launch, and every mood change in the chat, draws instantly.
class AssistantAvatarCache {
  AssistantAvatarCache._();

  static const _key = 'assistant_avatar_urls_v1';

  /// Off in tests, which have no file system for the image cache.
  static bool prefetchEnabled = true;

  /// The last saved {default url, state → url}, or empty.
  static ({String? avatarUrl, Map<String, String?> states}) read() {
    try {
      final raw = SharedPreferenceUtil.getString(_key);
      if (raw.isEmpty) return (avatarUrl: null, states: const {});
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final states = (data['states'] as Map? ?? const {})
          .map((k, v) => MapEntry(k.toString(), v?.toString()));
      return (avatarUrl: data['url']?.toString(), states: states);
    } catch (_) {
      return (avatarUrl: null, states: const {});
    }
  }

  /// Saves the URLs and warms the disk cache for any not seen before.
  static Future<void> remember(
      String? avatarUrl, Map<String, String?> states) async {
    if (avatarUrl == null && states.isEmpty) return;
    try {
      await SharedPreferenceUtil.putString(
        _key,
        jsonEncode({'url': avatarUrl, 'states': states}),
      );
    } catch (_) {}

    final urls = {avatarUrl, ...states.values}
        .whereType<String>()
        .where((u) => u.isNotEmpty)
        .toList();
    // In the background: saving the URLs must never wait on a download.
    if (prefetchEnabled) unawaited(_prefetch(urls));
  }

  static Future<void> _prefetch(List<String> urls) async {
    for (final url in urls) {
      try {
        final cached = await DefaultCacheManager().getFileFromCache(url);
        if (cached == null) await DefaultCacheManager().downloadFile(url);
      } catch (_) {
        // Decoration: a failed prefetch just means it loads on demand.
      }
    }
  }

  /// Signing out: the next account may be in another city, with another
  /// captain.
  static Future<void> clear() async {
    try {
      await SharedPreferenceUtil.putString(_key, '');
    } catch (_) {}
  }
}
