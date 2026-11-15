import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/keepy_uppy_repo.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_sim.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_uppy_page.dart';
import 'package:goal_master/features/games/presentation/keepy/alley_scene.dart';

const _easy = KeepyPhysics(
  hz: 120, target: 12, gravityMm: 8675, kickMm: 4268, hitMm: 282, sideMm: 1700,
  jitterMm: 285, windMm: 240, rampPermille: 7, halfWMm: 620, radiusMm: 110,
  startYMm: 900, startVyMm: 2800, cooldownFrames: 9, maxFrames: 28800,
);

/// Plays the server's part: replays whatever taps the app sends.
class _Server implements KeepyUppyRepo {
  List<KeepyTap>? sent;

  @override
  Future<Either<Failure, KeepyRound>> start(int challengeId) async => right(const KeepyRound(
      id: 'a1', seed: 424242, physics: _easy, difficulty: 'easy', title: 'سهل', rewardEligible: true));

  @override
  Future<Either<Failure, KeepyResult>> finish(String attemptId, List<KeepyTap> taps) async {
    sent = List.of(taps);
    final r = KeepySim.replay(_easy, 424242, taps);
    return right(KeepyResult(
      touches: r.touches, target: _easy.target, rejected: false, newBest: true,
      prize: PenaltyResult(won: r.won, goalsScored: r.touches, rewardEligible: true,
          rewardType: r.won ? 'coins' : null, rewardAmount: r.won ? 20 : 0),
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('taps on the falling ball are touches, and the server replay agrees', (tester) async {
    tester.view.physicalSize = const Size(440 * 3, 956 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final server = _Server();
    KeepySim? live;
    await tester.pumpWidget(MaterialApp(
      home: KeepyMatchPage(
        tier: const KeepyTier(challengeId: 1, difficulty: 'easy', title: 'سهل', description: '',
            target: 12, ballDifficulty: 15, unlockBookings: 0, unlocked: true, progress: 1),
        repo: server,
        sounds: false,
        forceTouch: true,
        debugOnSim: (s) => live = s,
      ),
    ));
    await tester.pump();
    expect(live, isNotNull);

    // Countdown and the flick-up.
    for (var i = 0; i < 360; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    final cam = AlleyCamera(const Size(440, 956));
    var lastTap = -100;
    for (var guard = 0; guard < 6000 && !live!.finished; guard++) {
      final s = live!;
      if (s.vy < 0 && s.y < 0.6 && s.frame - lastTap > 15) {
        lastTap = s.frame;
        final steer = (s.x * 0.35).clamp(-0.12, 0.12);
        await tester.tapAt(cam.project(s.x + steer, s.y));
      }
      await tester.pump(const Duration(milliseconds: 8));
    }

    expect(live!.won, isTrue, reason: 'reached ${live!.touches}');
    expect(find.text('12'), findsWidgets);

    // The celebration, then the verdict from the "server".
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(server.sent, isNotNull);
    final replay = KeepySim.replay(_easy, 424242, server.sent!);
    expect(replay.touches, live!.touches, reason: 'what the player saw is what the server counts');
    expect(replay.won, isTrue);
    expect(find.text('فزت بالتحدي!'), findsOneWidget);
  });

  testWidgets('a round with no touches still finishes and reports zero', (tester) async {
    final server = _Server();
    await tester.pumpWidget(MaterialApp(
      home: KeepyMatchPage(
        tier: const KeepyTier(challengeId: 1, difficulty: 'easy', title: 'سهل', description: '',
            target: 12, ballDifficulty: 15, unlockBookings: 0, unlocked: true, progress: 1),
        repo: server,
        sounds: false,
        forceTouch: true,
      ),
    ));
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(server.sent, isEmpty);
    expect(find.text('حظ أوفر المرة القادمة'), findsOneWidget);
  });
}
