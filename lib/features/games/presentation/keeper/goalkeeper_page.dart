import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/captain_ayoub_bubble.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/games/data/goalkeeper_repo.dart';

import '../keepy/captain_rig.dart';
import '../penalty/penalty_reward_card.dart';
import '../penalty/penalty_sounds.dart';
import '../penalty/penalty_painter.dart';
import '../penalty/penalty_world.dart';
import 'keeper_model.dart';
import '../game_errors.dart';

const _gold = Color(0xffffc928);
const _night = Color(0xff07110b);
const _mint = Color(0xff6ee7a8);

String _tierLabel(String d) => switch (d) {
      'easy' => 'سهل',
      'medium' => 'متوسط',
      'hard' => 'صعب',
      _ => d,
    };

Color _tierColor(String d) => switch (d) {
      'easy' => const Color(0xff4cc26a),
      'medium' => const Color(0xfff2a93b),
      _ => const Color(0xffe8534a),
    };

String _clock(int s) {
  final days = s ~/ 86400;
  final rest = s % 86400;
  final hms =
      '${(rest ~/ 3600).toString().padLeft(2, '0')}:${(rest % 3600 ~/ 60).toString().padLeft(2, '0')}:${(rest % 60).toString().padLeft(2, '0')}';
  return days > 0 ? '$days يوم و $hms' : hms;
}

// ===========================================================================
// Tier picker
// ===========================================================================

class GoalkeeperPage extends StatefulWidget {
  const GoalkeeperPage({super.key, this.repo, this.sounds = true});
  final GoalkeeperRepo? repo;
  final bool sounds;

  @override
  State<GoalkeeperPage> createState() => _GoalkeeperPageState();
}

class _GoalkeeperPageState extends State<GoalkeeperPage> {
  late final GoalkeeperRepo _repo = widget.repo ?? getIt<GoalkeeperRepo>();
  GoalkeeperStatus? _status;
  String? _error;
  Timer? _timer;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => CaptainAyoubBubble.suppressed.value++);
    _load();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.addPostFrameCallback((_) => CaptainAyoubBubble.suppressed.value--);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final res = await _repo.status();
    if (!mounted) return;
    res.fold((f) => setState(() => _error = friendlyGameError(f.errMessage)), (s) {
      _timer?.cancel();
      setState(() {
        _status = s;
        _cooldown = s.cooldownSeconds;
      });
      if (_cooldown > 0) {
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _cooldown = math.max(0, _cooldown - 1));
        });
      }
    });
  }

  Future<void> _play(GoalkeeperTier tier) async {
    HapticFeedback.selectionClick();
    var again = true;
    while (again && mounted) {
      again = await Navigator.of(context).push<bool>(MaterialPageRoute(
            builder: (_) => GoalkeeperMatchPage(tier: tier, repo: _repo, sounds: widget.sounds),
          )) ??
          false;
    }
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return Scaffold(
      backgroundColor: _night,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 280,
          backgroundColor: _night,
          foregroundColor: Colors.white,
          title: const Text('كن الحارس', style: TextStyle(fontWeight: FontWeight.w800)),
          flexibleSpace: const FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              _KeeperPreview(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Color(0x00000000), _night],
                    stops: [0, .5, 1],
                  ),
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          sliver: SliverList.list(children: [
            const Text('انت الحارس… وكابتن أيوب مدربك',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('انت الحارس. اضغط على المكان اللي بتمشي له الكرة، والحارس يرتمي ويصدها. كل تسديدة يختارها الخادم لحظة تنفيذها.',
                style: TextStyle(color: Colors.white70, height: 1.45)),
            const SizedBox(height: 14),
            if (status != null) ...[
              _Banner(status: status, cooldown: _cooldown),
              if (status.bestSaves > 0) ...[
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.emoji_events_outlined, color: _gold, size: 18),
                  const SizedBox(width: 6),
                  Text('أفضل نتيجة لك: ${status.bestSaves} تصديات',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ],
            ],
            const SizedBox(height: 16),
            if (_error != null)
              _ErrorBox(message: _error!, onRetry: _load)
            else if (status == null)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: _gold)))
            else if (status.tiers.isEmpty)
              const _ErrorBox(message: 'لا توجد مستويات متاحة حاليًا.')
            else
              for (final tier in status.tiers) ...[
                _TierCard(tier: tier, onTap: tier.unlocked && status.enabled ? () => _play(tier) : null),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 8),
            const _HowToPlay(),
          ]),
        ),
      ]),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.status, required this.cooldown});
  final GoalkeeperStatus status;
  final int cooldown;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String text) = !status.enabled
        ? (Icons.pause_circle_outline, Colors.white54, 'الألعاب متوقفة مؤقتًا.')
        : !status.verified
            ? (Icons.verified_user_outlined, const Color(0xfff2a93b), 'وثّق رقم هاتفك لتدخل سحب الجوائز عند الفوز.')
            : cooldown > 0
                ? (Icons.timer_outlined, Colors.white70, 'محاولتك المؤهلة القادمة بعد ${_clock(cooldown)} — يمكنك التدرّب الآن.')
                : (Icons.card_giftcard_rounded, _gold, 'محاولتك القادمة مؤهلة لسحب جائزة إذا وصلت للهدف.');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, height: 1.35))),
      ]),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, this.onTap});
  final GoalkeeperTier tier;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(tier.difficulty);
    final locked = !tier.unlocked;
    final bars = (tier.shooterSkill / 20).ceil().clamp(1, 5);
    return Material(
      color: const Color(0xff112019),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: locked ? Colors.white10 : color.withValues(alpha: .45)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(20)),
                child: Text(_tierLabel(tier.difficulty),
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(tier.title,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
              Icon(locked ? Icons.lock_rounded : Icons.play_circle_fill_rounded,
                  color: locked ? Colors.white38 : color, size: 30),
            ]),
            if (tier.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(tier.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.sports_handball_rounded, size: 16, color: Colors.white54),
              const SizedBox(width: 4),
              Text('صدّ ${tier.savesToWin} من ${tier.shotsTotal}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('قوة التسديد', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 6),
              for (var i = 1; i <= 5; i++)
                Container(
                  width: 6,
                  height: 5.0 + i * 3,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(color: i <= bars ? color : Colors.white12, borderRadius: BorderRadius.circular(2)),
                ),
            ]),
            if (locked) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                    value: tier.progress.clamp(0, 1), minHeight: 6, backgroundColor: Colors.white10, color: color),
              ),
              const SizedBox(height: 6),
              Text('يُفتح بعد ${tier.unlockBookings} حجوزات مكتملة',
                  style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
            ],
          ]),
        ),
      ),
    );
  }
}

class _HowToPlay extends StatelessWidget {
  const _HowToPlay();

  @override
  Widget build(BuildContext context) {
    const tips = [
      (Icons.touch_app_rounded, 'اضغط على المكان اللي تتوقع الكرة تجي فيه، والحارس يرتمي له.'),
      (Icons.bolt_rounded, 'كل ما ضغطت أبكر، وصلت أبعد. التسديدات في الزوايا تحتاج قرار سريع.'),
      (Icons.psychology_alt_rounded, 'تقدر تتوقع قبل التسديدة… لكن لو غلطت الاتجاه ما عاد تلحق.'),
      (Icons.sports_handball_rounded, 'الحارس يرتمي بحركة حقيقية: لو وصل بدري يمسكها، ولو وصل على الحافة يبعدها.'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xff0d1913), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('كيف تلعب؟', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final (icon, text) in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 19, color: _gold),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, height: 1.4))),
            ]),
          ),
      ]),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xff1d1414), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
          ],
        ]),
      );
}

/// The stadium from behind the spot, the keeper on his line, the ball
/// waiting — the same world as the shoot-out.
class _KeeperPreview extends StatefulWidget {
  const _KeeperPreview();
  @override
  State<_KeeperPreview> createState() => _KeeperPreviewState();
}

class _KeeperPreviewState extends State<_KeeperPreview> with SingleTickerProviderStateMixin {
  final _scene = PenaltyScene()
    ..zoom = 1.35
    ..zoomFocus = const V3(0, 1.0, Pitch.goalLineZ);
  final _frame = ValueNotifier(0);
  late final Ticker _ticker;
  double _last = 0;
  PenaltyBackdrop? _backdrop;
  Size? _building;
  ui.Image? _keeper;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final now = elapsed.inMicroseconds / 1e6;
      final dt = (now - _last).clamp(0.0, 0.05);
      _last = now;
      _scene
        ..clock += dt
        ..keeper = KeeperMotion.idle(_scene.clock);
      _frame.value++;
    })
      ..start();
    loadKeeperSprite().then((img) {
      if (mounted) {
        setState(() => _keeper = img);
      } else {
        img.dispose();
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _backdrop?.dispose();
    _keeper?.dispose();
    super.dispose();
  }

  void _ensureBackdrop(Size size) {
    if (_backdrop?.size == size || _building == size || size.isEmpty) return;
    _building = size;
    PenaltyBackdrop.build(size, MediaQuery.devicePixelRatioOf(context)).then((b) {
      if (!mounted || _building != size) return b.dispose();
      setState(() {
        _backdrop?.dispose();
        _backdrop = b;
      });
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final size = box.biggest;
        _ensureBackdrop(size);
        return CustomPaint(
          size: size,
          painter: PenaltyPainter(scene: _scene, backdrop: _backdrop, keeper: _keeper, repaint: _frame),
        );
      });
}

// ===========================================================================
// The match
// ===========================================================================

enum _Phase { loading, intro, fetching, runup, flight, after, finishing, done, error }

enum _Mood { calm, happy, sad }

class GoalkeeperMatchPage extends StatefulWidget {
  const GoalkeeperMatchPage({super.key, required this.tier, required this.repo, this.sounds = true, this.debugOnShot});
  final GoalkeeperTier tier;
  final GoalkeeperRepo repo;
  final bool sounds;

  /// Tests and the preview only: told about each shot as it's revealed,
  /// with a way to turn goal metres into a screen point.
  @visibleForTesting
  final void Function(GoalkeeperShot shot, Offset Function(double x, double y) toScreen)? debugOnShot;

  @override
  State<GoalkeeperMatchPage> createState() => _GoalkeeperMatchPageState();
}

class _GoalkeeperMatchPageState extends State<GoalkeeperMatchPage> with SingleTickerProviderStateMixin {
  final _scene = PenaltyScene();
  final _frame = ValueNotifier(0);
  final _rng = math.Random();
  late final Ticker _ticker;
  late final PenaltySounds _sounds = PenaltySounds(enabled: widget.sounds);

  PenaltyBackdrop? _backdrop;
  Size? _building;
  Size _size = Size.zero;
  ui.Image? _keeperImage;
  CaptainArt? _art;

  _Phase _phase = _Phase.loading;
  String? _error;
  GoalkeeperRound? _round;
  GoalkeeperShot? _shot;
  final List<bool?> _results = [];
  int _saves = 0;
  GoalkeeperResult? _final;

  double _last = 0, _phaseTime = 0, _shake = 0, _celebrate = 0;
  bool _whistled = false;

  // The current shot.
  BallFlight? _flight;
  KeeperMotion? _motion;
  double _kickT = 0, _timeScale = 1, _afterT = 0;
  ({double x, double y})? _diveAt;
  int? _diveMs;
  bool _diveSent = false, _impactDone = false;
  (int, int)? _padDir;
  GoalkeeperVerdict? _verdict;

  // Captain Ayoub, coaching from the corner.
  _Mood _mood = _Mood.calm;
  String _coach = 'ركّز… الكرة أسرع مما تتوقع';
  int _coachId = 0;

  String? _banner;
  Color _bannerColor = Colors.white;
  int _bannerId = 0;

  int get _need => _round?.savesToWin ?? widget.tier.savesToWin;
  int get _total => _round?.shotsTotal ?? widget.tier.shotsTotal;
  int get _taken => _results.where((r) => r != null).length;

  static V3 _goal(double x, double y) => V3(x, y, Pitch.goalLineZ);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _sounds.init();
    CaptainArt.shared().then((a) {
      if (mounted) setState(() => _art = a);
    }).catchError((_) {});
    loadKeeperSprite().then((img) {
      if (mounted) {
        setState(() => _keeperImage = img);
      } else {
        img.dispose();
      }
    }).catchError((_) {});
    _start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sounds.dispose();
    _backdrop?.dispose();
    _keeperImage?.dispose();
    super.dispose();
  }

  void _say(String line, _Mood mood) => setState(() {
        _coach = line;
        _mood = mood;
        _coachId++;
      });

  String _pick(List<String> lines) => lines[_rng.nextInt(lines.length)];

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.loading;
      _error = null;
    });
    final res = await widget.repo.start(widget.tier.challengeId);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _phase = _Phase.error;
        _error = friendlyGameError(f.errMessage);
      }),
      (round) {
        _round = round;
        _results
          ..clear()
          ..addAll(List<bool?>.filled(round.shotsTotal, null));
        _saves = 0;
        _resetForShot();
        setState(() => _phase = _Phase.intro);
        _phaseTime = 0;
        _whistled = false;
        _say('صدّ ${round.savesToWin} من ${round.shotsTotal}. اختار الاتجاه بالأسهم!', _Mood.calm);
      },
    );
  }

  void _resetForShot() {
    _scene
      ..ball = Pitch.ballSpot
      ..trail.clear()
      ..ripple = null
      ..boardMessage = null
      ..zoom = 1
      ..reticle = null
      ..guide = const [];
    _flight = null;
    _motion = null;
    _kickT = 0;
    _timeScale = 1;
    _diveAt = null;
    _diveMs = null;
    _padDir = null;
    _diveSent = false;
    _impactDone = false;
    _verdict = null;
    _afterT = 0;
  }

  // ---- frame loop ----------------------------------------------------------

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _last).clamp(0.0, 0.05);
    _last = now;
    final s = _scene;
    s.clock += dt;
    _phaseTime += dt;
    s.flash = math.max(0, s.flash - dt * 2.2);
    s.fx.update(dt);
    s.squash = math.max(0, s.squash - dt * 7);
    s.speed = math.max(0, s.speed - dt * 1.6);
    _shake *= math.exp(-dt * 9);
    s.shake = _shake < 0.2 ? Offset.zero : Offset((_rng.nextDouble() - 0.5) * _shake, (_rng.nextDouble() - 0.5) * _shake);
    if (_celebrate > 0) {
      _celebrate = math.max(0, _celebrate - dt * 0.3);
      s.crowdJump = (math.sin(s.clock * 11).abs() * 3.2) * math.min(1, _celebrate * 2);
      if (_rng.nextDouble() < 0.25) s.flashSeed = _rng.nextInt(1 << 30);
    } else {
      s.crowdJump = 0;
    }
    final tense = _phase == _Phase.runup ? 1.0 : 0.0;
    s.tension += (tense * 0.6 - s.tension) * math.min(1, dt * 3);

    switch (_phase) {
      case _Phase.intro:
        s.keeper = KeeperMotion.idle(s.clock);
        if (_phaseTime > 0.8 && !_whistled) {
          _whistled = true;
          _sounds.play(PenaltySfx.whistle);
        }
        if (_phaseTime > 1.4) _nextShot();
      case _Phase.fetching:
        s.keeper = KeeperMotion.idle(s.clock);
      case _Phase.runup:
        _runup();
      case _Phase.flight:
        _fly(dt);
      case _Phase.after:
        _fly(dt);
        _afterShot(dt);
      default:
        s.keeper = KeeperMotion.idle(s.clock);
    }
    _frame.value++;
  }

  /// The striker's run-up: the keeper drifts back to the middle and sets.
  void _runup() {
    final shot = _shot!;
    final t = (_phaseTime / (shot.runupMs / 1000)).clamp(0.0, 1.0);
    final idle = KeeperMotion.idle(_scene.clock);
    final settle = Curves.easeInOut.transform(t);
    _scene.keeper = KeeperPose(
        V3(idle.centre.x * (1 - settle), idle.centre.y - 0.04 * settle, idle.centre.z), KeeperFrame.ready, 0,
        sy: idle.sy - 0.05 * settle);
    // The ball twitches as the striker plants his foot.
    if (t > 0.82) _scene.ballSpin += 0.02;
    if (t >= 1) _kick();
  }

  void _kick() {
    final shot = _shot!;
    final s = _scene;
    _flight = BallFlight(
      aim: ShotAim(shot.x / Pitch.goalWidth + 0.5, shot.y / Pitch.goalHeight),
      curl: shot.curl,
      duration: shot.flightMs / 1000,
    );
    _kickT = 0;
    _timeScale = 1;
    _sounds.play(PenaltySfx.kick);
    Future<void>.delayed(const Duration(milliseconds: 45), () {
      if (mounted) _sounds.play(PenaltySfx.whoosh);
    });
    _sounds.crowdLevel(0.55);
    HapticFeedback.mediumImpact();
    if (_size != Size.zero) {
      final cam = PenaltyCamera(_size);
      s.fx.strike(cam.project(Pitch.ballSpot), Pitch.ballRadius * cam.scaleAt(0), power: 0.6);
    }
    s
      ..squash = 1
      ..speed = 0.7;
    _shake = 5;
    setState(() => _phase = _Phase.flight);
    _phaseTime = 0;
    // Guessed during the run-up: he goes the moment the ball is struck.
    if (_diveAt != null) _commitDive();
  }

  void _commitDive() {
    final dive = _diveAt!, f = _flight!, shot = _shot!;
    final g = KeeperModel.glove(dive.x, dive.y, _diveMs, shot.flightMs);
    _motion = KeeperMotion(
      reactAt: math.max(_diveMs ?? 0, KeeperModel.minReactMs) / 1000,
      arriveAt: f.duration,
    )..diveTo(_goal(g.x, g.y), 0);
    _sendDive();
  }

  void _fly(double dt) {
    final f = _flight;
    if (f == null) return;
    final s = _scene;
    // After a dive, wait for the server near the end rather than guess.
    final waiting = _diveAt != null && _verdict == null && _kickT >= f.duration * 0.8;
    final target = waiting ? 0.12 : 1.0;
    _timeScale += (target - _timeScale) * math.min(1, dt * (waiting ? 14 : 8));
    final prev = _kickT;
    _kickT += dt * _timeScale;
    if (_diveAt != null && _verdict == null) _kickT = math.min(_kickT, f.duration * 0.97);

    final set = KeeperPose(V3(0, KeeperSprite.standingHeight / 2 - 0.04, Pitch.keeperZ), KeeperFrame.ready, 0, sy: 0.95);
    s.keeper = _motion?.at(_kickT, 0) ?? set;

    var ball = f.at(_kickT);
    if (f.caught && _kickT >= f.duration) ball = s.keeper.hands;
    if (_size != Size.zero && _kickT < f.duration + 0.25) {
      s.trail.add(PenaltyCamera(_size).project(s.ball));
      if (s.trail.length > 12) s.trail.removeAt(0);
    } else if (s.trail.isNotEmpty) {
      s.trail.removeAt(0);
    }
    s
      ..ball = ball
      ..ballSpin += dt * _timeScale * (_kickT < f.duration ? 30 : 8)
      ..spinTilt = f.curl * 0.6
      ..netClock = _kickT;

    final lands = _motion?.landsAt;
    if (lands != null && prev < lands && _kickT >= lands && _size != Size.zero) {
      final cam = PenaltyCamera(_size);
      final k = s.keeper.centre;
      s.fx.landing(cam.project(V3(k.x, 0.05, k.z)), cam.scaleAt(k.z));
      HapticFeedback.lightImpact();
    }

    // Never moved: tell the server once the ball is in.
    if (_phase == _Phase.flight && !_diveSent && _kickT >= f.duration - 0.03) _sendDive();

    if (!_impactDone && _kickT >= f.duration) {
      final v = _verdict ?? (_diveAt == null ? _standingVerdict() : null);
      if (v != null) _impact(v);
    }
  }

  void _onTap(PointerDownEvent e) {
    if (_size == Size.zero || _diveAt != null) return;
    if (_phase != _Phase.runup && _phase != _Phase.flight) return;
    final f = _flight;
    if (_phase == _Phase.flight && f != null && _kickT >= f.duration - 0.04) return;
    final w = PenaltyCamera(_size).onPlane(e.localPosition, Pitch.goalLineZ);
    _diveAt = (
      x: w.x.clamp(-KeeperModel.halfWidth - 0.3, KeeperModel.halfWidth + 0.3),
      y: w.y.clamp(0.0, KeeperModel.bar + 0.3),
    );
    _diveMs = _phase == _Phase.runup ? 0 : (_kickT * 1000).round();
    _scene.reticle = ShotAim(_diveAt!.x / Pitch.goalWidth + 0.5, _diveAt!.y / Pitch.goalHeight);
    _scene.guideReach = 1;
    HapticFeedback.selectionClick();
    if (_phase == _Phase.flight) _commitDive();
  }

  /// The pad, PlayStation style: pick a direction and he goes that way,
  /// reading the ball's line along it (how far and how high) the way a
  /// keeper does once he has committed to a side. The middle stays put.
  void _onPad(int dx, int dy) {
    if (_diveAt != null) return;
    if (_phase != _Phase.runup && _phase != _Phase.flight) return;
    final f = _flight;
    if (_phase == _Phase.flight && f != null && _kickT >= f.duration - 0.04) return;
    const sx = KeeperModel.startX, sy = KeeperModel.startY;
    ({double x, double y}) point;
    if (dx == 0 && dy == 0) {
      point = (x: sx, y: sy);
    } else {
      // Direction in goal metres; the goal is wide and short.
      var vx = dx * 3.0, vy = dy * 1.15;
      final len = math.sqrt(vx * vx + vy * vy);
      vx /= len;
      vy /= len;
      final shot = _shot!;
      final along = (shot.x - sx) * vx + (shot.y - sy) * vy;
      // The right way: he goes as far as the ball's line. The wrong way: he
      // has committed, so it's a full dive that way anyway.
      final reach = dx == 0
          ? (along > 0 ? along.clamp(0.4, 1.5) : 1.2)
          : (along > 0.4 ? along.clamp(1.1, 3.7) : 2.6);
      point = (x: sx + vx * reach, y: (sy + vy * reach).clamp(0.15, KeeperModel.bar));
    }
    _padDir = (dx, dy);
    _diveAt = point;
    _diveMs = _phase == _Phase.runup ? 0 : (_kickT * 1000).round();
    _scene.reticle = ShotAim(point.x / Pitch.goalWidth + 0.5, point.y / Pitch.goalHeight);
    _scene.guideReach = 1;
    HapticFeedback.mediumImpact();
    setState(() {});
    if (_phase == _Phase.flight) _commitDive();
  }

  Future<void> _sendDive() async {
    final shot = _shot, round = _round;
    if (shot == null || round == null || _diveSent) return;
    _diveSent = true;
    final dive = _diveAt;
    for (var attempt = 0; attempt < 4; attempt++) {
      if (attempt > 0) await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      if (!mounted) return;
      final res = await widget.repo.dive(round.id, shot.number, diveMs: dive == null ? null : _diveMs, x: dive?.x, y: dive?.y);
      if (!mounted) return;
      final ok = res.fold((_) => null, (v) => v);
      if (ok != null) {
        _verdict = ok;
        _applyOutcome(ok);
        return;
      }
    }
    setState(() {
      _phase = _Phase.error;
      _error = 'انقطع الاتصال أثناء التسديدة. تحقق من الاتصال ثم أعد المحاولة.';
    });
  }

  /// Decide how the ball carries on past the moment: in the gloves, off
  /// them, or into the net.
  void _applyOutcome(GoalkeeperVerdict v) {
    final f = _flight;
    if (f == null || f.outcome != null) return;
    if (v.saved) {
      f.outcome = KickOutcome.save;
      final dx = f.target.x - v.gloveX, dy = f.target.y - v.gloveY;
      f.caught = dx * dx + dy * dy < 0.34 * 0.34 && f.target.y < 2.0;
      f.parrySide = f.target.x >= v.gloveX ? 1 : -1;
    } else {
      f.outcome = KickOutcome.goal;
    }
  }

  /// What the server will say about a keeper who never moved.
  GoalkeeperVerdict _standingVerdict() {
    final shot = _shot!;
    final saved = KeeperModel.saved(shot.x, shot.y, KeeperModel.startX, KeeperModel.startY);
    final saves = _saves + (saved ? 1 : 0), taken = _taken + 1, left = _total - taken;
    return GoalkeeperVerdict(
        saved: saved,
        gloveX: KeeperModel.startX,
        gloveY: KeeperModel.startY,
        saves: saves,
        shotsTaken: taken,
        decided: left <= 0 || saves >= _need || saves + left < _need);
  }

  void _impact(GoalkeeperVerdict v) {
    _impactDone = true;
    _applyOutcome(v);
    final f = _flight!;
    final s = _scene;
    final idx = _shot!.number - 1;
    setState(() {
      if (idx >= 0 && idx < _results.length) _results[idx] = v.saved;
      _saves = v.saves;
      _phase = _Phase.after;
    });
    _phaseTime = 0;
    _afterT = 0;
    final hit = f.target;
    if (v.saved) {
      _sounds.play(PenaltySfx.glove);
      _sounds.play(PenaltySfx.cheer, volume: 0.75);
      HapticFeedback.heavyImpact();
      _celebrate = 0.8;
      if (_size != Size.zero) {
        final cam = PenaltyCamera(_size);
        s.fx.sparks(cam.project(hit), (cam.scaleAt(hit.z) / 40).clamp(0.6, 1.6), const Color(0xffe8f6ff));
      }
      _showBanner(f.caught ? 'مسكها!' : 'تصدّي!', _mint);
      _say(_pick(['يا سلام عليك!', 'حارس عالمي!', 'هذا هو! كمّل هكي', 'قرأتها صح!']), _Mood.happy);
    } else {
      s.ripple = NetRipple(V3(hit.x, hit.y, 0), f.duration + 0.04, 0.5);
      _sounds.play(PenaltySfx.net);
      _sounds.play(PenaltySfx.groan);
      HapticFeedback.mediumImpact();
      _shake = 8;
      _showBanner('هدف!', const Color(0xffff6b5f));
      final early = _diveAt != null && (_diveMs ?? 0) == 0;
      _say(
          _diveAt == null
              ? _pick(['لازم ترتمي! اختار اتجاه بالأسهم', 'ما تتحركش؟ اضغط سهم بسرعة!'])
              : early
                  ? 'خمّنت قبل التسديدة… مرات تصيب ومرات لا'
                  : _pick(['كانت قريبة! أسرع شوية', 'ولا يهمك، اللي بعدها', 'ركّز على الزاوية']),
          _Mood.sad);
    }
    _sounds.crowdLevel(0.32);
  }

  void _afterShot(double dt) {
    _afterT += dt;
    // Watch him land and pick himself up, then the next one.
    if (_afterT > 2.3 && _verdict != null) {
      if (_verdict!.decided || _taken >= _total) {
        _finish();
      } else {
        _resetForShot();
        _nextShot();
      }
    }
  }

  Future<void> _nextShot() async {
    final round = _round;
    if (round == null) return;
    setState(() {
      _phase = _Phase.fetching;
      _banner = null;
    });
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
      final res = await widget.repo.shot(round.id);
      if (!mounted) return;
      final shot = res.fold((_) => null, (s) => s);
      if (shot != null) {
        _shot = shot;
        if (_size != Size.zero) {
          final cam = PenaltyCamera(_size);
          widget.debugOnShot?.call(shot, (x, y) => cam.project(_goal(x, y)));
        }
        setState(() => _phase = _Phase.runup);
        _phaseTime = 0;
        _sounds.crowdLevel(0.45);
        if (_taken > 0) _say(_pick(['خلّك جاهز…', 'عينك على الكرة', 'اقرأ التسديدة!', 'هذي مهمة!']), _Mood.calm);
        return;
      }
    }
    setState(() {
      _phase = _Phase.error;
      _error = 'تعذر تحميل التسديدة. تحقق من الاتصال ثم أعد المحاولة.';
    });
  }

  void _showBanner(String text, Color color) => setState(() {
        _banner = text;
        _bannerColor = color;
        _bannerId++;
      });

  Future<void> _finish() async {
    final round = _round;
    if (round == null || !mounted || _phase == _Phase.finishing) return;
    setState(() {
      _phase = _Phase.finishing;
      _banner = null;
    });
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future<void>.delayed(Duration(milliseconds: 700 * attempt));
      final res = await widget.repo.complete(round.id);
      if (!mounted) return;
      final ok = res.fold((_) => null, (r) => r);
      if (ok != null) {
        setState(() {
          _final = ok;
          _phase = _Phase.done;
        });
        if (ok.prize.won) {
          _celebrate = 1.4;
          _sounds.play(PenaltySfx.cheer);
          if (_size != Size.zero) _scene.fx.confetti(_size, count: 140);
          _say('انت حارس حقيقي! 🧤', _Mood.happy);
        } else {
          _say('قريب! جرب مرة ثانية', _Mood.sad);
        }
        if (ok.prize.rewardType == 'coins') {
          try {
            context.read<CoinsCubit>().getBalance();
          } catch (_) {}
        }
        return;
      }
    }
    setState(() {
      _phase = _Phase.error;
      _error = 'تعذر حفظ نتيجة الجولة. تحقق من الاتصال ثم أعد المحاولة.';
    });
  }

  Future<bool> _confirmLeave() async {
    if (_phase == _Phase.done || _phase == _Phase.error || _round == null) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الخروج من الجولة؟'),
        content: const Text('ستنتهي الجولة الحالية ولن تُحتسب.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('متابعة اللعب')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('خروج')),
        ],
      ),
    );
    return leave ?? false;
  }

  void _ensureBackdrop(Size size) {
    _size = size;
    if (_backdrop?.size == size || _building == size || size.isEmpty) return;
    _building = size;
    PenaltyBackdrop.build(size, MediaQuery.devicePixelRatioOf(context)).then((b) {
      if (!mounted || _building != size) return b.dispose();
      setState(() {
        _backdrop?.dispose();
        _backdrop = b;
      });
    });
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) Navigator.of(context).pop(false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(fit: StackFit.expand, children: [
          Positioned.fill(
            child: LayoutBuilder(builder: (context, box) {
              _ensureBackdrop(box.biggest);
              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onTap,
                child: CustomPaint(
                  size: box.biggest,
                  painter: PenaltyPainter(scene: _scene, backdrop: _backdrop, keeper: _keeperImage, repaint: _frame),
                ),
              );
            }),
          ),
          if (_backdrop == null)
            const Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: _night, child: Center(child: CircularProgressIndicator(color: _gold))),
              ),
            ),
          Positioned(top: 0, left: 0, right: 0, child: SafeArea(bottom: false, child: _hud())),
          if (_banner != null) _bannerWidget(),
          Positioned(
            left: 12,
            right: 182,
            bottom: 0,
            child: SafeArea(top: false, child: _CoachBar(art: _art, mood: _mood, line: _coach, id: _coachId)),
          ),
          Positioned(
            right: 12,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DivePad(
                  enabled: (_phase == _Phase.runup || _phase == _Phase.flight) && _diveAt == null,
                  chosen: _padDir,
                  onPick: _onPad,
                ),
              ),
            ),
          ),
          if (_phase == _Phase.runup && _taken < 2 && _diveAt == null) const _TapHint(),
          if (_phase == _Phase.finishing)
            const Positioned(top: 160, left: 0, right: 0, child: Center(child: CircularProgressIndicator(color: _gold))),
          if (_phase == _Phase.error) _errorOverlay(),
          if (_phase == _Phase.done && _final != null) _resultOverlay(),
        ]),
      ),
    );
  }

  Widget _hud() {
    final color = _tierColor(widget.tier.difficulty);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _GlassButton(
          icon: Icons.close_rounded,
          onTap: () async {
            if (await _confirmLeave() && mounted) Navigator.of(context).pop(false);
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xcc07110b),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: .2), borderRadius: BorderRadius.circular(10)),
                  child: Text(_tierLabel(widget.tier.difficulty),
                      style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('$_saves / $_need تصديات',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
                if (_round?.rewardEligible == true) const Icon(Icons.card_giftcard_rounded, color: _gold, size: 18),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < _results.length; i++)
                  _ShotDot(state: _results[i], current: i == _taken && _phase != _Phase.done),
              ]),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        _GlassButton(
          icon: PenaltySounds.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          onTap: () async {
            await _sounds.setMuted(!PenaltySounds.muted);
            if (mounted) setState(() {});
          },
        ),
      ]),
    );
  }

  Widget _bannerWidget() => IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.45),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_bannerId),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.scale(scale: 0.4 + 0.6 * v, child: child),
            child: Text(
              _banner!,
              style: TextStyle(
                color: _bannerColor,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 18),
                  Shadow(color: Colors.black87, offset: Offset(0, 3), blurRadius: 2),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _errorOverlay() => Positioned.fill(
        child: ColoredBox(
          color: Colors.black87,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 44),
                const SizedBox(height: 12),
                Text(_error ?? 'حدث خطأ غير متوقع.',
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('رجوع', style: TextStyle(color: Colors.white70))),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
                    onPressed: () {
                      if (_round == null) {
                        _start();
                      } else if (_shot != null && _verdict == null && _diveSent) {
                        _diveSent = false;
                        setState(() => _phase = _Phase.flight);
                        _sendDive();
                      } else if (_taken >= _total || (_verdict?.decided ?? false)) {
                        _finish();
                      } else {
                        _resetForShot();
                        _nextShot();
                      }
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      );

  Widget _resultOverlay() {
    final r = _final!;
    final summary = r.prize.won
        ? 'صدّيت ${r.saves} تسديدات${r.newBest ? ' — رقم قياسي جديد!' : ''}'
        : '${r.saves} تصديات — كنت تحتاج ${r.savesToWin}';
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => ColoredBox(
          color: Colors.black.withValues(alpha: 0.55 * v),
          child: Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 40 * (1 - v)), child: child)),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: PenaltyResultPanel(
              result: r.prize,
              goalsToWin: r.savesToWin,
              kicksTaken: _taken,
              summary: summary,
              lostNote: 'اضغط على المكان اللي تمشي له الكرة بأسرع ما يمكن بعد التسديدة. التخمين قبلها مخاطرة.',
              onPlayAgain: () => Navigator.of(context).pop(true),
              onExit: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nine buttons laid out like the goal: corners, sides, high, low, and the
/// middle to stand his ground. Arrows point where he'll go, as seen from
/// behind the spot (right on screen is right in the goal).
class _DivePad extends StatelessWidget {
  const _DivePad({required this.enabled, required this.chosen, required this.onPick});
  final bool enabled;
  final (int, int)? chosen;
  final void Function(int dx, int dy) onPick;

  static const _icons = {
    (-1, 1): Icons.north_west_rounded,
    (0, 1): Icons.north_rounded,
    (1, 1): Icons.north_east_rounded,
    (-1, 0): Icons.west_rounded,
    (0, 0): Icons.adjust_rounded,
    (1, 0): Icons.east_rounded,
    (-1, -1): Icons.south_west_rounded,
    (0, -1): Icons.south_rounded,
    (1, -1): Icons.south_east_rounded,
  };

  @override
  Widget build(BuildContext context) => Directionality(
        // Directions are physical: keep the grid left-to-right even in RTL.
        textDirection: TextDirection.ltr,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0x9907110b),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final dy in const [1, 0, -1])
              Row(mainAxisSize: MainAxisSize.min, children: [
                for (final dx in const [-1, 0, 1]) _button(dx, dy),
              ]),
          ]),
        ),
      );

  Widget _button(int dx, int dy) {
    final picked = chosen == (dx, dy);
    final centre = dx == 0 && dy == 0;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: picked
            ? _gold
            : enabled
                ? Colors.white.withValues(alpha: centre ? .1 : .16)
                : Colors.white.withValues(alpha: .05),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? () => onPick(dx, dy) : null,
          child: SizedBox(
            width: 45,
            height: 45,
            child: Icon(_icons[(dx, dy)],
                size: centre ? 20 : 26,
                color: picked ? Colors.black : (enabled ? Colors.white : Colors.white30)),
          ),
        ),
      ),
    );
  }
}

/// Captain Ayoub in the corner: his face (calm, delighted or gutted) and a
/// line of advice.
class _CoachBar extends StatelessWidget {
  const _CoachBar({required this.art, required this.mood, required this.line, required this.id});
  final CaptainArt? art;
  final _Mood mood;
  final String line;
  final int id;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xff16402a),
                border: Border.all(
                    color: switch (mood) {
                      _Mood.happy => _mint,
                      _Mood.sad => const Color(0xffff8a65),
                      _Mood.calm => _gold,
                    },
                    width: 2.5),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
              ),
              child: ClipOval(
                child: art == null
                    ? const Icon(Icons.sports_soccer, color: Colors.white54)
                    : CustomPaint(painter: _FacePainter(art!, mood)),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                        position: Tween(begin: const Offset(0.1, 0), end: Offset.zero).animate(a), child: child)),
                child: Container(
                  key: ValueKey(id),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xe607110b),
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(16),
                      topEnd: Radius.circular(16),
                      bottomEnd: Radius.circular(16),
                      bottomStart: Radius.circular(4),
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    const Text('كابتن أيوب',
                        style: TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(line, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.3)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      );
}

class _FacePainter extends CustomPainter {
  _FacePainter(this.art, this.mood);
  final CaptainArt art;
  final _Mood mood;

  // Head crops of each pose (asset pixels).
  static const _crops = {
    _Mood.calm: Rect.fromLTWH(185, 0, 260, 260),
    _Mood.happy: Rect.fromLTWH(235, 5, 260, 260),
    _Mood.sad: Rect.fromLTWH(295, 5, 260, 260),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final img = switch (mood) {
      _Mood.calm => art.wave,
      _Mood.happy => art.celebrate,
      _Mood.sad => art.shrug,
    };
    canvas.drawImageRect(img, _crops[mood]!, Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) => old.mood != mood || old.art != art;
}

class _ShotDot extends StatelessWidget {
  const _ShotDot({required this.state, required this.current});
  final bool? state;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final (Color fill, IconData? icon) = switch (state) {
      true => (const Color(0xff2fbf5b), Icons.back_hand_rounded),
      false => (const Color(0xffe0483e), Icons.sports_soccer),
      null => (Colors.transparent, null),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: current ? _gold : Colors.white38, width: current ? 2.2 : 1.4),
      ),
      child: icon == null ? null : Icon(icon, size: 14, color: Colors.white),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xaa07110b),
        shape: const CircleBorder(side: BorderSide(color: Colors.white12)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: Colors.white, size: 22)),
        ),
      );
}

class _TapHint extends StatefulWidget {
  const _TapHint();
  @override
  State<_TapHint> createState() => _TapHintState();
}

class _TapHintState extends State<_TapHint> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Align(
          alignment: const Alignment(0, 0.22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) => Transform.scale(scale: 0.9 + 0.15 * _c.value, child: child),
              child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Text('اختار اتجاه الارتماء بالأسهم\nأو اضغط على مكان الكرة في المرمى',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}
