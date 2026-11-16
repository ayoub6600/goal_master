import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/assistant/data/assistant_avatar_cache.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoRepo implements AssistantRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The captain's face used to wait for the history request on every launch.
void main() {
  setUp(() async {
    AssistantAvatarCache.prefetchEnabled = false;
    SharedPreferences.setMockInitialValues({});
    await SharedPreferenceUtil.getInstance();
  });

  test('the avatar URLs survive a restart and seed the cubit', () async {
    const url = 'https://example.test/storage/25/conversions/captain-app.webp';
    final cubit = AssistantChatCubit(_NoRepo());
    // Nothing saved yet: no avatar to draw.
    expect(cubit.state.avatarUrl, isNull);

    // Saving without network: the prefetch fails quietly.
    await AssistantAvatarCache.remember(url, {'default': url});

    final next = AssistantChatCubit(_NoRepo());
    expect(next.state.avatarUrl, url);
    expect(next.state.avatarFor('welcome'), url);
  });

  test('sign-out clears it', () async {
    await AssistantAvatarCache.remember('https://x.test/a.webp', const {});
    await AssistantAvatarCache.clear();
    expect(AssistantAvatarCache.read().avatarUrl, isNull);
  });
}
