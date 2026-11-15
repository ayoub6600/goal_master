// Dev-only entry point: opens the games against an in-memory fake server so
// they can be played and screenshotted on a simulator without touching any
// real backend.  Run with:
//   flutter run -t tool/game_preview.dart
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goal_master/features/coins/data/repo/coins_repo.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/games/presentation/moving_target_game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/goalkeeper_repo.dart';
import 'package:goal_master/features/games/data/moving_target_game_repo.dart';
import 'package:goal_master/features/games/presentation/cups/cup_game_page.dart';
import 'package:goal_master/features/games/data/prediction_repo.dart';
import 'package:goal_master/features/games/presentation/prediction/prediction_page.dart';
import 'package:goal_master/features/games/data/keepy_uppy_repo.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';
import 'package:goal_master/features/games/presentation/keeper/goalkeeper_page.dart';
import 'package:goal_master/features/games/presentation/keeper/keeper_model.dart';
import 'package:goal_master/features/games/presentation/keepy/alley_scene.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_sim.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_uppy_page.dart';
import 'package:goal_master/features/games/presentation/penalty/penalty_shootout_page.dart';
import 'package:goal_master/features/games/presentation/penalty/penalty_world.dart';

class _FakeCoins implements CoinsRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  GetIt.instance.registerSingleton<MovingTargetGameRepo>(_FakeCups());
  runApp(BlocProvider(create: (_) => CoinsCubit(_FakeCoins()), child: const _PreviewApp()));
}

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

/// The goalkeeper server, in memory: the same shot picker and reach model.
class _FakeKeeper implements GoalkeeperRepo {
  final _rng = math.Random();
  final _shots = <int, GoalkeeperShot>{};
  final _revealed = <int, DateTime>{};
  int _taken = 0, _saves = 0;
  static const _skill = 25, _total = 5, _need = 3;

  @override
  Future<Either<Failure, GoalkeeperStatus>> status() async => right(const GoalkeeperStatus(
        enabled: true, verified: true, cooldownSeconds: 0, bestSaves: 2,
        tiers: [
          GoalkeeperTier(challengeId: 1, difficulty: 'easy', title: 'كن الحارس — سهل', description: 'كابتن أيوب سيسدد 5 ركلات. صدّ 3 لتفوز.',
              shotsTotal: 5, savesToWin: 3, shooterSkill: 25, unlockBookings: 0, unlocked: true, progress: 1),
          GoalkeeperTier(challengeId: 2, difficulty: 'medium', title: 'كن الحارس — متوسط', description: '',
              shotsTotal: 5, savesToWin: 3, shooterSkill: 55, unlockBookings: 2, unlocked: true, progress: 1),
          GoalkeeperTier(challengeId: 3, difficulty: 'hard', title: 'كن الحارس — صعب', description: '',
              shotsTotal: 6, savesToWin: 3, shooterSkill: 80, unlockBookings: 5, unlocked: false, progress: 0.4),
        ],
      ));

  @override
  Future<Either<Failure, GoalkeeperRound>> start(int challengeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _shots.clear();
    _taken = 0;
    _saves = 0;
    return right(const GoalkeeperRound(
        id: 'g1', shotsTotal: _total, savesToWin: _need, shooterSkill: _skill, difficulty: 'easy',
        title: 'سهل', rewardEligible: true, runupMs: 1100));
  }

  @override
  Future<Either<Failure, GoalkeeperShot>> shot(String attemptId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final n = _taken + 1;
    return right(_shots.putIfAbsent(n, () {
      _revealed[n] = DateTime.now();
      // Same recipe as GoalkeeperModel::shot.
      const k = _skill / 100;
      double r() => _rng.nextDouble();
      final flight = ((1050 - 470 * k) * (0.93 + 0.14 * r())).round();
      final side = r() < 0.5 ? -1 : 1;
      final kind = r(), u = r();
      final ax = kind < 0.10 ? 0.2 + 0.5 * u : (kind < 0.10 + 0.25 + 0.45 * k ? 2.3 + 1.0 * u : 0.8 + 1.5 * u);
      final high = r() < 0.2 + 0.35 * k;
      final y = high ? 1.6 + 0.6 * r() : 0.2 + 1.2 * r();
      return GoalkeeperShot(number: n, x: double.parse((side * ax).toStringAsFixed(2)), y: double.parse(y.toStringAsFixed(2)),
          flightMs: flight, curl: double.parse(((r() * 2 - 1) * (0.2 + 0.8 * k)).toStringAsFixed(2)), runupMs: 1100);
    }));
  }

  @override
  Future<Either<Failure, GoalkeeperVerdict>> dive(String attemptId, int shotNumber, {int? diveMs, double? x, double? y}) async {
    await Future<void>.delayed(Duration(milliseconds: 120 + _rng.nextInt(200)));
    final s = _shots[shotNumber]!;
    final g = KeeperModel.glove(x, y, diveMs, s.flightMs);
    final saved = KeeperModel.saved(s.x, s.y, g.x, g.y);
    _taken++;
    if (saved) _saves++;
    final left = _total - _taken;
    return right(GoalkeeperVerdict(
        saved: saved, gloveX: double.parse(g.x.toStringAsFixed(2)), gloveY: double.parse(g.y.toStringAsFixed(2)),
        saves: _saves, shotsTaken: _taken, decided: left <= 0 || _saves >= _need || _saves + left < _need));
  }

  @override
  Future<Either<Failure, GoalkeeperResult>> complete(String attemptId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final won = _saves >= _need;
    return right(GoalkeeperResult(
      saves: _saves, savesToWin: _need, newBest: won,
      prize: PenaltyResult(
        won: won, goalsScored: _saves, rewardEligible: true,
        rewardType: won ? 'coins' : null, rewardTitle: won ? '30 كوينز' : null, rewardAmount: won ? 30 : 0),
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePredictions implements PredictionRepo {
  final _mine = <int, Score>{};

  PredictionMatch _m(int id, String h, String a, String comp, Duration from, {Score? result, int? points, bool exact = false}) {
    final now = DateTime.now();
    final kickoff = now.add(from);
    return PredictionMatch(
        id: id, home: h, away: a, competition: comp, kickoff: kickoff, open: result == null && from > Duration.zero,
        locksAt: kickoff, status: result == null ? 'scheduled' : 'finished', result: result,
        mine: _mine[id] ?? (result != null ? (home: 2, away: 1) : null), points: points, exact: exact);
  }

  @override
  Future<Either<Failure, PredictionBoard>> board() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return right(PredictionBoard(
      enabled: true, verified: true, exactPoints: 3, resultPoints: 1, prizes: const [100, 50, 25],
      upcoming: [
        _m(1, 'الأهلي طرابلس', 'الاتحاد', 'الدوري الليبي', const Duration(hours: 5, minutes: 12)),
        _m(2, 'ريال مدريد', 'برشلونة', 'الدوري الإسباني', const Duration(days: 2, hours: 3)),
        _m(3, 'الأهلي بنغازي', 'النصر', 'الدوري الليبي', const Duration(minutes: -20)),
      ],
      recent: [
        _m(4, 'ليفربول', 'مانشستر سيتي', 'الدوري الإنجليزي', const Duration(days: -1), result: (home: 2, away: 1), points: 3, exact: true),
        _m(5, 'إنتر', 'ميلان', 'الدوري الإيطالي', const Duration(days: -2), result: (home: 0, away: 2), points: 0),
      ],
      week: const PredictionTable(start: '2026-11-16', end: '2026-11-22', awarded: false, myRank: 2, myPoints: 7, leaders: [
        PredictionLeader(rank: 1, name: 'سالم ا.', points: 9, exact: 2, me: false, coins: 0),
        PredictionLeader(rank: 2, name: 'أيوب ب.', points: 7, exact: 2, me: true, coins: 0),
        PredictionLeader(rank: 3, name: 'محمد ع.', points: 5, exact: 1, me: false, coins: 0),
        PredictionLeader(rank: 4, name: 'علي س.', points: 4, exact: 0, me: false, coins: 0),
      ]),
      lastWeek: const PredictionTable(start: '2026-11-09', end: '2026-11-15', awarded: true, myRank: null, myPoints: 0, leaders: [
        PredictionLeader(rank: 1, name: 'هشام م.', points: 12, exact: 3, me: false, coins: 100),
        PredictionLeader(rank: 2, name: 'سالم ا.', points: 10, exact: 2, me: false, coins: 50),
        PredictionLeader(rank: 3, name: 'طارق ف.', points: 8, exact: 1, me: false, coins: 25),
      ]),
    ));
  }

  @override
  Future<Either<Failure, PredictionMatch>> predict(int matchId, int home, int away) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _mine[matchId] = (home: home, away: away);
    final b = (await board()).getOrElse(() => throw StateError('board'));
    return right(b.upcoming.firstWhere((m) => m.id == matchId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The cups server, in memory: same start/swap recipe as the backend.
class _FakeCups implements MovingTargetGameRepo {
  final _rng = math.Random();
  int _winning = 0;
  bool _hit = false;

  @override
  Future<Either<Failure, MovingGameStatus>> status() async => right(const MovingGameStatus(
        enabled: true, rewardEligible: true, rewardAmount: 10, cooldownSeconds: 0, completedBookings: 7,
        progression: {'legendary_customer': {'completed': 7, 'required': 100, 'progress': 0.07}},
        legendaryVoucherAmount: 50, legendaryVoucherCode: null, verified: true, rewardSystemEnabled: true,
        rewardBudgetAvailable: true, rewardOptions: [],
        availableGames: [
          GameChallengeStatus(key: 'cup', gameType: 'cup_shuffle', title: 'تحدي الأكواب', description: '',
              difficulty: 'easy', questionCount: 1, durationSeconds: 25, unlockBookings: 0, winningScore: 100,
              isActive: true, unlocked: true, progress: 1),
        ],
      ));

  @override
  Future<Either<Failure, MovingGameAttempt>> start({String gameKey = 'moving_target'}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final start = _rng.nextInt(3);
    final pos = [0, 1, 2];
    final swaps = <List<int>>[];
    for (var m = 0; m < 9; m++) {
      final l = _rng.nextInt(3);
      var r = _rng.nextInt(3);
      while (r == l) {
        r = _rng.nextInt(3);
      }
      swaps.add([l, r]);
      for (var c = 0; c < 3; c++) {
        if (pos[c] == l) {
          pos[c] = r;
        } else if (pos[c] == r) {
          pos[c] = l;
        }
      }
    }
    _winning = pos[start];
    return right(MovingGameAttempt(
        id: 'c1', gameKey: gameKey, gameType: 'cup_shuffle', durationMs: 25000, remainingMs: 25000,
        winningScore: 100, phases: const [], cupStartIndex: start, cupSwaps: swaps, questions: const [],
        rewardEligible: true, rewardAmount: 10, title: 'تحدي الأكواب'));
  }

  @override
  Future<Either<Failure, MovingGameShot>> shot(
      {required String attemptId, required String eventId, bool wheelComplete = false, int? scenarioIndex,
      int? answerIndex, int? lane, double? x, double? y}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _hit = answerIndex == _winning;
    return right(MovingGameShot(hit: _hit, score: _hit ? 100 : 0, hits: _hit ? 1 : 0, points: 0, answerIndex: _winning));
  }

  @override
  Future<Either<Failure, MovingGameResult>> complete(String attemptId) async => right(MovingGameResult(
      score: _hit ? 100 : 0, hits: _hit ? 1 : 0, rewardAmount: _hit ? 10 : 0, won: _hit, rewardEligible: true,
      rewardType: _hit ? 'coins' : null, rewardTitle: _hit ? '10 كوينز' : null));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _nav = GlobalKey<NavigatorState>();

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: _nav,
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
  /// Remote control for checking visuals without touching the simulator:
  /// write commands into <app tmp>/preview_cmd.txt, one per line —
  ///   slow N | open NAME | back | tap X Y | swipe X1 Y1 X2 Y2 MS
  Timer? _remote;

  @override
  void initState() {
    super.initState();
    _remote = Timer.periodic(const Duration(milliseconds: 250), (_) => _poll());
  }

  Future<void> _poll() async {
    final f = File('${Directory.systemTemp.path}/preview_cmd.txt');
    if (!f.existsSync()) return;
    final lines = f.readAsLinesSync();
    f.deleteSync();
    for (final line in lines) {
      final a = line.trim().split(RegExp(r'\s+'));
      if (a.isEmpty || a.first.isEmpty) continue;
      switch (a.first) {
        case 'slow':
          timeDilation = double.parse(a[1]);
        case 'back':
          _nav.currentState?.maybePop();
        case 'open':
          final page = _pages[a[1]];
          if (page != null) _nav.currentState?.push(MaterialPageRoute<bool>(builder: (_) => page()));
        case 'tap':
          final at = Offset(double.parse(a[1]), double.parse(a[2]));
          final id = _pointer++;
          GestureBinding.instance.handlePointerEvent(PointerDownEvent(pointer: id, position: at));
          GestureBinding.instance.handlePointerEvent(PointerUpEvent(pointer: id, position: at));
        case 'swipe':
          await _swipe(Offset(double.parse(a[1]), double.parse(a[2])), Offset(double.parse(a[3]), double.parse(a[4])),
              int.parse(a[5]));
      }
    }
  }

  Future<void> _swipe(Offset from, Offset to, int ms) async {
    final id = _pointer++;
    final b = GestureBinding.instance;
    b.handlePointerEvent(PointerDownEvent(pointer: id, position: from));
    const steps = 8;
    var last = from;
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(Duration(milliseconds: ms ~/ steps));
      final p = Offset.lerp(from, to, i / steps)!;
      b.handlePointerEvent(PointerMoveEvent(pointer: id, position: p, delta: p - last));
      last = p;
    }
    b.handlePointerEvent(PointerUpEvent(pointer: id, position: to));
  }

  KeepyTier _tier(int id, String d, int target, int bd) => KeepyTier(
      challengeId: id, difficulty: d, title: d, description: '', target: target,
      ballDifficulty: bd, unlockBookings: 0, unlocked: true, progress: 1);

  static const _keeperTier = GoalkeeperTier(challengeId: 1, difficulty: 'easy', title: 'سهل', description: '',
      shotsTotal: 5, savesToWin: 3, shooterSkill: 25, unlockBookings: 0, unlocked: true, progress: 1);

  late final Map<String, Widget Function()> _pages = {
    'penalty': () => PenaltyMatchPage(
          tier: const PenaltyTier(
              challengeId: 1, difficulty: 'medium', title: 'متوسط', description: '',
              kicksTotal: 5, goalsToWin: 3, unlockBookings: 0, unlocked: true, progress: 1),
          repo: _FakePenalty(),
        ),
    'keepy': () => KeepyMatchPage(tier: _tier(1, 'easy', 12, 15), repo: _FakeKeepy(15)),
    'keepy_auto': () => KeepyMatchPage(tier: _tier(1, 'easy', 12, 15), repo: _FakeKeepy(15), debugOnSim: _autoplay, forceTouch: true),
    'keepy_pick': () => KeepyUppyPage(repo: _FakeKeepy(15)),
    'keeper': () => GoalkeeperMatchPage(tier: _keeperTier, repo: _FakeKeeper()),
    'keeper_auto': () => GoalkeeperMatchPage(tier: _keeperTier, repo: _FakeKeeper(), debugOnShot: _keeperBot),
    'keeper_pick': () => GoalkeeperPage(repo: _FakeKeeper()),
    'predict': () => PredictionPage(repo: _FakePredictions()),
    'cups': () => CupGamePage(gameKey: 'cup', title: 'تحدي الأكواب', repo: _FakeCups()),
    'hub': () => const GamesRewardsView(),
  };

  @override
  void dispose() {
    _remote?.cancel();
    _bot?.dispose();
    super.dispose();
  }
  KeepySim? _live;
  Ticker? _bot;
  int _lastTap = -100, _pointer = 900;
  double _tapAt = 0.45;
  final _rng = math.Random();


  /// Dives for the keeper with a real tap: a human-ish reaction after the
  /// strike, aimed near (not exactly at) where the shot is going.
  void _keeperBot(GoalkeeperShot shot, Offset Function(double x, double y) goal) {
    final delay = shot.runupMs + 220 + _rng.nextInt(160);
    Future<void>.delayed(Duration(milliseconds: delay), () {
      final at = goal(shot.x + (_rng.nextDouble() - 0.5) * 0.6, shot.y + (_rng.nextDouble() - 0.5) * 0.4);
      final id = _pointer++;
      GestureBinding.instance.handlePointerEvent(PointerDownEvent(pointer: id, position: at));
      GestureBinding.instance.handlePointerEvent(PointerUpEvent(pointer: id, position: at));
    });
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
              context, KeepyMatchPage(tier: tier(1, 'easy', 12, 15), repo: _FakeKeepy(15), debugOnSim: _autoplay, forceTouch: true)),
          child: const Text('تنطيط الكرة — لعب تلقائي'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _open(
              context,
              GoalkeeperMatchPage(
                tier: const GoalkeeperTier(challengeId: 1, difficulty: 'easy', title: 'سهل', description: '',
                    shotsTotal: 5, savesToWin: 3, shooterSkill: 25, unlockBookings: 0, unlocked: true, progress: 1),
                repo: _FakeKeeper(),
              )),
          child: const Text('كن الحارس'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => _open(
              context,
              GoalkeeperMatchPage(
                tier: const GoalkeeperTier(challengeId: 1, difficulty: 'easy', title: 'سهل', description: '',
                    shotsTotal: 5, savesToWin: 3, shooterSkill: 25, unlockBookings: 0, unlocked: true, progress: 1),
                repo: _FakeKeeper(),
                debugOnShot: _keeperBot,
              )),
          child: const Text('كن الحارس — لعب تلقائي'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _open(context, PredictionPage(repo: _FakePredictions())),
          child: const Text('توقع النتيجة'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _open(context, GoalkeeperPage(repo: _FakeKeeper())),
          child: const Text('صفحة اختيار الحارس'),
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
