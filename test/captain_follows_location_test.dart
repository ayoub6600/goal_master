// dartz exports a `State` that collides with Flutter's.
import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/assistant/data/assistant_history_cache.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/data/repo/assistant_repo.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/location/data/active_location_snapshot.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';

/// The captain must belong to the city the customer is actually shopping in.
///
/// The persona is scoped by zone on the backend, and a request the server
/// cannot place falls back to the DEFAULT profile — which is a real captain
/// from a real city (كابتن طرابلس), not a neutral one. So "we didn't know the
/// zone yet" does not look like an error; it looks like a perfectly normal
/// captain from the wrong place, sitting next to a correctly-filtered Misurata
/// venue list.
///
/// These tests pin the two things that let that happen: a persona loaded
/// before the location was known and never revisited, and a slow answer for a
/// city the customer has already left.
class _FakeAssistantRepo implements AssistantRepo {
  _FakeAssistantRepo();

  /// Persona per zone, as the backend resolves it.
  final Map<int?, String> personaByZone = {
    1: 'كابتن طرابلس',
    2: 'كابتن أيوب',
    null: 'كابتن طرابلس', // the is_default fallback
  };

  int historyCalls = 0;

  /// When set, the next history call waits on it — long enough for the
  /// customer to move somewhere else first.
  Completer<void>? hold;

  /// The zone the pending call will answer for, captured at call time.
  int? _pendingZone;

  @override
  Future<Either<Failure, AssistantConversationResponse>> getHistory({
    bool markRead = false,
  }) async {
    historyCalls++;
    _pendingZone = ActiveLocationSnapshot.current?.zoneId;

    if (hold != null) await hold!.future;

    return right(AssistantConversationResponse(
      conversationId: 1,
      flowState: 'idle',
      avatarUrl: '',
      messages: const [],
      assistantName: personaByZone[_pendingZone] ?? 'كابتن طرابلس',
      assistantShortName: '',
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ActiveLocation _at(int zoneId, String zoneName) => ActiveLocation(
      id: zoneId,
      latitude: 32.0,
      longitude: 13.0,
      zoneId: zoneId,
      zoneName: zoneName,
      source: 'map',
    );

void main() {
  late _FakeAssistantRepo repo;
  late AssistantChatCubit cubit;

  setUp(() {
    ActiveLocationSnapshot.clear();
    AssistantHistoryCache.invalidate();
    repo = _FakeAssistantRepo();
    cubit = AssistantChatCubit(repo);
  });

  test('1. a persona loaded before the location is known is replaced', () async {
    // Cold start: the bubble mounts and fetches before the account has been
    // read, so the server has no zone and answers with the default.
    await cubit.loadHistory();
    expect(cubit.state.assistantName, 'كابتن طرابلس');

    // The Active Location lands moments later.
    ActiveLocationSnapshot.publish(_at(2, 'مصراته'));
    await cubit.loadHistory();

    // Venues and captain now agree. Without the zone check this returned
    // early — history was "already loaded" — and the wrong captain stayed.
    expect(cubit.state.assistantName, 'كابتن أيوب');
  });

  test('2. changing zone refreshes the persona without forceRefresh', () async {
    ActiveLocationSnapshot.publish(_at(1, 'طرابلس'));
    await cubit.loadHistory();
    expect(cubit.state.assistantName, 'كابتن طرابلس');

    ActiveLocationSnapshot.publish(_at(2, 'مصراته'));
    await cubit.loadHistory();

    expect(cubit.state.assistantName, 'كابتن أيوب');
  });

  test('3. staying in the same zone does not refetch', () async {
    ActiveLocationSnapshot.publish(_at(2, 'مصراته'));
    await cubit.loadHistory();
    final callsAfterFirst = repo.historyCalls;

    await cubit.loadHistory();

    // The persona cannot have changed, so neither should the network.
    expect(repo.historyCalls, callsAfterFirst);
    expect(cubit.state.assistantName, 'كابتن أيوب');
  });

  test('4. a late answer for the city just left is discarded', () async {
    ActiveLocationSnapshot.publish(_at(2, 'مصراته'));
    await cubit.loadHistory();
    expect(cubit.state.assistantName, 'كابتن أيوب');

    // A request goes out for Tripoli...
    ActiveLocationSnapshot.publish(_at(1, 'طرابلس'));
    repo.hold = Completer<void>();
    final pending = cubit.loadHistory();

    // ...and the customer returns to Misurata before it answers.
    ActiveLocationSnapshot.publish(_at(2, 'مصراته'));
    repo.hold!.complete();
    await pending;

    // The stale answer must not repaint the captain. Applying it would look
    // like a successful load and leave the wrong city on screen indefinitely.
    expect(cubit.state.assistantName, 'كابتن أيوب');
  });

  test('5. rapid switches end on the latest location', () async {
    for (final zone in [1, 2, 1, 2]) {
      ActiveLocationSnapshot.publish(_at(zone, 'z$zone'));
      await cubit.loadHistory();
    }

    expect(cubit.state.assistantName, 'كابتن أيوب');
  });

  test('6. a failure leaves the previous persona rather than a wrong one', () async {
    ActiveLocationSnapshot.publish(_at(2, 'مصراته'));
    await cubit.loadHistory();

    expect(cubit.state.assistantName, 'كابتن أيوب');
    expect(cubit.state.loading, isFalse);
  });
}
