import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/goalkeeper_repo.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';
import 'package:goal_master/features/games/presentation/keeper/goalkeeper_page.dart';
import 'package:goal_master/features/games/presentation/keeper/keeper_model.dart';

/// Plays the server: fixed shots, judged by the shared reach model.
class _Server implements GoalkeeperRepo {
  final shots = const [
    GoalkeeperShot(number: 1, x: 2.0, y: 1.2, flightMs: 1000, curl: 0, runupMs: 1100),
    GoalkeeperShot(number: 2, x: -2.4, y: 0.6, flightMs: 1000, curl: 0.3, runupMs: 1100),
    GoalkeeperShot(number: 3, x: 1.5, y: 1.8, flightMs: 1000, curl: 0, runupMs: 1100),
  ];
  final dives = <int, ({int? ms, double? x, double? y})>{};
  int taken = 0, saves = 0;

  @override
  Future<Either<Failure, GoalkeeperRound>> start(int challengeId) async => right(const GoalkeeperRound(
      id: 'a1', shotsTotal: 3, savesToWin: 2, shooterSkill: 25, difficulty: 'easy', title: 'سهل',
      rewardEligible: true, runupMs: 1100));

  @override
  Future<Either<Failure, GoalkeeperShot>> shot(String attemptId) async => right(shots[taken]);

  @override
  Future<Either<Failure, GoalkeeperVerdict>> dive(String attemptId, int shotNumber, {int? diveMs, double? x, double? y}) async {
    dives[shotNumber] = (ms: diveMs, x: x, y: y);
    final s = shots[shotNumber - 1];
    final g = KeeperModel.glove(x, y, diveMs, s.flightMs);
    final saved = KeeperModel.saved(s.x, s.y, g.x, g.y);
    taken++;
    if (saved) saves++;
    return right(GoalkeeperVerdict(
        saved: saved, gloveX: g.x, gloveY: g.y, saves: saves, shotsTaken: taken,
        decided: saves >= 2 || taken >= 3 || saves + (3 - taken) < 2));
  }

  @override
  Future<Either<Failure, GoalkeeperResult>> complete(String attemptId) async => right(GoalkeeperResult(
      saves: saves, savesToWin: 2, newBest: true,
      prize: PenaltyResult(won: saves >= 2, goalsScored: saves, rewardEligible: true, rewardType: saves >= 2 ? 'coins' : null, rewardAmount: saves >= 2 ? 20 : 0)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _tier = GoalkeeperTier(
    challengeId: 1, difficulty: 'easy', title: 'سهل', description: '', shotsTotal: 3, savesToWin: 2,
    shooterSkill: 25, unlockBookings: 0, unlocked: true, progress: 1);

void main() {
  testWidgets('diving to where each shot goes saves it and wins the round', (tester) async {
    tester.view.physicalSize = const Size(440 * 3, 956 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final server = _Server();
    GoalkeeperShot? current;
    Offset Function(double x, double y)? toScreen;

    await tester.pumpWidget(MaterialApp(
      home: GoalkeeperMatchPage(
        tier: _tier,
        repo: server,
        sounds: false,
        debugOnShot: (s, map) {
          current = s;
          toScreen = map;
        },
      ),
    ));

    for (var shot = 1; shot <= 2; shot++) {
      // Until the shot is revealed and the striker has run up and struck.
      for (var i = 0; i < 400 && (current?.number != shot); i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(current?.number, shot);
      for (var i = 0; i < 65; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      // A quick, accurate dive just after the strike.
      await tester.tapAt(toScreen!(current!.x, current!.y));
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(server.dives[shot]!.ms, isNotNull);
      expect(server.dives[shot]!.x, closeTo(current!.x, 0.05), reason: 'the tap maps back to the same goal point');
    }

    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(server.saves, 2);
    expect(find.text('فزت بالتحدي!'), findsOneWidget);
  });

  testWidgets('the arrow pad: going the right way saves it', (tester) async {
    tester.view.physicalSize = const Size(440 * 3, 956 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final server = _Server();
    await tester.pumpWidget(MaterialApp(home: GoalkeeperMatchPage(tier: _tier, repo: server, sounds: false)));

    // First shot goes right (x = 2.0, y = 1.2): wait for the strike, press →.
    for (var i = 0; i < 200 && find.byIcon(Icons.east_rounded).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    for (var i = 0; i < 160; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (server.dives.isNotEmpty) break;
      if (i == 75) await tester.tap(find.byIcon(Icons.east_rounded));
    }
    for (var i = 0; i < 100 && server.taken < 1; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(server.dives[1]!.x, greaterThan(1.5), reason: 'went right, along the ball\'s line');
    expect(server.saves, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('standing still lets a corner shot in, and tells the server so', (tester) async {
    tester.view.physicalSize = const Size(440 * 3, 956 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final server = _Server();
    await tester.pumpWidget(MaterialApp(home: GoalkeeperMatchPage(tier: _tier, repo: server, sounds: false)));

    for (var i = 0; i < 200 && server.taken < 1; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(server.dives[1], isNotNull);
    expect(server.dives[1]!.ms, isNull, reason: 'no dive was made');
    expect(server.saves, 0);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(find.text('هدف!'), findsOneWidget);
  });
}
