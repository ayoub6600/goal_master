// Dev-only entry point: opens the games against an in-memory fake server so
// they can be played and screenshotted on a simulator without touching any
// real backend.  Run with:
//   flutter run -t tool/game_preview.dart
import 'dart:math' as math;

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/keepy_uppy_repo.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';
import 'package:goal_master/features/games/presentation/keepy/alley_scene.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_sim.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_uppy_page.dart';
import 'package:goal_master/features/games/presentation/penalty/penalty_shootout_page.dart';
import 'package:goal_master/features/games/presentation/penalty/penalty_world.dart';

void main() => runApp(const _PreviewApp());

/// Server-side physics for a ball_difficulty / target pair (mirror of
/// KeepyUppySimulator::params).
KeepyPhysics _keepyParams(int d, int target) {
  final g = 8000 + 45 * d;
  return KeepyPhysics(
    hz: 120,
    target: target,
    gravityMm: g,
    kickMm: (math.sqrt(2 * (g / 1000) * 1.05) * 1000).round(),
    hitMm: (300 - 1.2 * d).round(),
    sideMm: 1700,
    jitterMm: 150 + 9 * d,
    windMm: 16 * d,
    rampPermille: 6 + d ~/ 10,
    halfWMm: 620,
    radiusMm: 110,
    startYMm: 900,
    startVyMm: 2800,
    cooldownFrames: 9,
    maxFrames: 120 * 240,
  );
}

class _FakeKeepy implements KeepyUppyRepo {
  _FakeKeepy(this.difficulty);
  final int difficulty;
  KeepyPhysics? _p;
  int _seed = 0;

  @override
  Future<Either<Failure, KeepyStatus>> status() async => right(KeepyStatus(
        enabled: true,
        verified: true,
        cooldownSeconds: 0,
        bestTouches: 9,
        tiers: [
          for (final (id, d, t, bd) in const [(1, 'easy', 12, 15), (2, 'medium', 20, 45), (3, 'hard', 30, 75)])
            KeepyTier(
                challengeId: id, difficulty: d, title: d, description: '', target: t,
                ballDifficulty: bd, unlockBookings: 0, unlocked: true, progress: 1),
        ],
      ));

  @override
  Future<Either<Failure, KeepyRound>> start(int challengeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _seed = math.Random().nextInt(1 << 30) + 1;
    _p = _keepyParams(difficulty, challengeId == 3 ? 30 : (challengeId == 2 ? 20 : 12));
    return right(KeepyRound(
        id: 'k$_seed', seed: _seed, physics: _p!, difficulty: 'easy', title: 'سهل', rewardEligible: true));
  }

  @override
  Future<Either<Failure, KeepyResult>> finish(String attemptId, List<KeepyTap> taps) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final r = KeepySim.replay(_p!, _seed, taps);
    return right(KeepyResult(
      touches: r.touches,
      target: _p!.target,
      rejected: false,
      newBest: true,
      prize: PenaltyResult(
        won: r.won,
        goalsScored: r.touches,
        rewardEligible: true,
        rewardType: r.won ? 'coupon' : null,
        rewardTitle: r.won ? 'خصم 15% على حجزك القادم' : null,
        rewardReference: r.won ? 'GMKUPREVIEW' : null,
        rewardAmount: r.won ? 15 : 0,
        rewardDetails: r.won
            ? const {'code': 'GMKUPREVIEW', 'percent': 15, 'max_discount': 20, 'branch_name': 'ملاعب الجدار'}
            : const {},
      ),
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePenalty implements PenaltyShootoutRepo {
  final _rng = math.Random();
  int _taken = 0, _goals = 0;

  @override
  Future<Either<Failure, PenaltyAttempt>> start(int challengeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _taken = 0;
    _goals = 0;
    return right(const PenaltyAttempt(
        id: 'p1', kicksTotal: 5, kicksTaken: 0, goalsScored: 0, goalsToWin: 3,
        difficulty: 'medium', title: 'متوسط', rewardEligible: true));
  }

  @override
  Future<Either<Failure, PenaltyKickResult>> kick(
      {required String attemptId, required String eventId, required double aimX, required double aimY}) async {
    await Future<void>.delayed(Duration(milliseconds: 150 + _rng.nextInt(250)));
    final aim = ShotAim(aimX, aimY);
    final keeperZone = _rng.nextInt(9);
    final outcome = aim.offTarget
        ? 'miss'
        : aim.onWoodwork
            ? 'post'
            : (keeperZone == aim.zone ? 'save' : 'goal');
    _taken++;
    if (outcome == 'goal') _goals++;
    return right(PenaltyKickResult(
        outcome: outcome, scored: outcome == 'goal', keeperZone: keeperZone, kicksTaken: _taken, goalsScored: _goals));
  }

  @override
  Future<Either<Failure, PenaltyResult>> complete(String attemptId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final won = _goals >= 3;
    return right(PenaltyResult(
      won: won,
      goalsScored: _goals,
      rewardEligible: true,
      rewardType: won ? 'coins' : null,
      rewardTitle: won ? '50 كوينز' : null,
      rewardAmount: won ? 50 : 0,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
        home: const _Menu(),
      );
}

class _Menu extends StatefulWidget {
  const _Menu();

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  KeepySim? _live;
  Ticker? _bot;
  int _lastTap = -100, _pointer = 900;
  double _tapAt = 0.45;
  final _rng = math.Random();

  @override
  void dispose() {
    _bot?.dispose();
    super.dispose();
  }

  /// Plays keepy-uppy with real pointer events, the same path a finger
  /// takes, mixing tap heights so every move gets shown.
  void _autoplay(KeepySim s) {
    _live = s;
    _lastTap = -100;
    _bot?.dispose();
    _bot = Ticker((_) {
      final sim = _live;
      if (sim == null || sim.finished) return;
      if (sim.vy < 0 && sim.y < _tapAt && sim.frame - _lastTap > 15) {
        _lastTap = sim.frame;
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        final size = view.physicalSize / view.devicePixelRatio;
        final steer = (sim.x * 0.35).clamp(-0.12, 0.12);
        final at = AlleyCamera(size).project(sim.x + steer, sim.y);
        final id = _pointer++;
        GestureBinding.instance.handlePointerEvent(PointerDownEvent(pointer: id, position: at));
        GestureBinding.instance.handlePointerEvent(PointerUpEvent(pointer: id, position: at));
        final r = _rng.nextDouble();
        _tapAt = r < 0.4 ? 0.42 : (r < 0.72 ? 0.85 : (r < 0.88 ? 1.3 : 1.62));
      }
    })
      ..start();
  }

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    KeepyTier tier(int id, String d, int target, int bd) => KeepyTier(
        challengeId: id, difficulty: d, title: d, description: '', target: target,
        ballDifficulty: bd, unlockBookings: 0, unlocked: true, progress: 1);
    return Scaffold(
      appBar: AppBar(title: const Text('معاينة الألعاب')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SwitchListTile(
          title: const Text('حركة بطيئة ×5 (للفحص)'),
          value: timeDilation > 1,
          onChanged: (v) => setState(() => timeDilation = v ? 5 : 1),
        ),
        FilledButton(
          onPressed: () => _open(
              context,
              PenaltyMatchPage(
                tier: const PenaltyTier(
                    challengeId: 1, difficulty: 'medium', title: 'متوسط', description: '',
                    kicksTotal: 5, goalsToWin: 3, unlockBookings: 0, unlocked: true, progress: 1),
                repo: _FakePenalty(),
              )),
          child: const Text('ركلات الترجيح'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _open(context, KeepyMatchPage(tier: tier(1, 'easy', 12, 15), repo: _FakeKeepy(15))),
          child: const Text('تنطيط الكرة — سهل'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => _open(
              context, KeepyMatchPage(tier: tier(1, 'easy', 12, 15), repo: _FakeKeepy(15), debugOnSim: _autoplay)),
          child: const Text('تنطيط الكرة — لعب تلقائي'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _open(context, KeepyUppyPage(repo: _FakeKeepy(15))),
          child: const Text('صفحة اختيار التنطيط'),
        ),
      ]),
    );
  }
}
