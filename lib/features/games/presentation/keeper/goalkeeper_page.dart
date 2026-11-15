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
import 'keeper_model.dart';
import 'keeper_scene.dart';

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
    res.fold((f) => setState(() => _error = f.errMessage), (s) {
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
            const Text('كابتن أيوب يسدد… وانت الحارس',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('اضغط على المكان اللي بتمشي له الكرة لترتمي وتصدها. كل تسديدة يختارها الخادم لحظة تنفيذها.',
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
      (Icons.visibility_rounded, 'في المستوى السهل، راقب كابتن أيوب: يميل شوية ناحية تسديدته.'),
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

/// The keeper's view with Captain Ayoub waiting on the spot.
class _KeeperPreview extends StatefulWidget {
  const _KeeperPreview();
  @override
  State<_KeeperPreview> createState() => _KeeperPreviewState();
}

class _KeeperPreviewState extends State<_KeeperPreview> with SingleTickerProviderStateMixin {
  final _scene = KeeperScene()..captainZ = KeeperView.spotZ + 0.8;
  final _frame = ValueNotifier(0);
  late final Ticker _ticker;
  double _last = 0;
  KeeperBackdrop? _backdrop;
  Size? _building;
  CaptainArt? _art;
  ui.Image? _glove;

  @override
  void initState() {
    super.initState();
    _scene.captain
      ..setPose(CaptainPose.rig)
      ..poseBlend = 1;
    _ticker = createTicker((elapsed) {
      final now = elapsed.inMicroseconds / 1e6;
      final dt = (now - _last).clamp(0.0, 0.05);
      _last = now;
      _scene.clock += dt;
      _scene.captain.update(dt);
      // A little sway on the line, like a keeper waiting.
      _scene.gloveX = math.sin(_scene.clock * 1.3) * 0.35;
      _frame.value++;
    })
      ..start();
    CaptainArt.shared().then((a) {
      if (mounted) setState(() => _art = a);
    }).catchError((_) {});
    loadGlove().then((g) {
      if (mounted) {
        setState(() => _glove = g);
      } else {
        g.dispose();
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _backdrop?.dispose();
    _glove?.dispose();
    super.dispose();
  }

  void _ensureBackdrop(Size size) {
    if (_backdrop?.size == size || _building == size || size.isEmpty) return;
    _building = size;
    KeeperBackdrop.build(size, MediaQuery.devicePixelRatioOf(context)).then((b) {
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
        final v = KeeperView(size);
        _scene
          ..ballAt = v.world(0, 0.11, KeeperView.spotZ - 0.4)
          ..ballR = 0.11 * v.scaleAt(KeeperView.spotZ - 0.4);
        return CustomPaint(
          size: size,
          painter: KeeperPainter(scene: _scene, backdrop: _backdrop, art: _art, glove: _glove, repaint: _frame),
        );
      });
}

// ===========================================================================
// The match
// ===========================================================================

enum _Phase { loading, intro, fetching, runup, flight, after, finishing, done, error }

class GoalkeeperMatchPage extends StatefulWidget {
  const GoalkeeperMatchPage({super.key, required this.tier, required this.repo, this.sounds = true, this.debugOnShot});
  final GoalkeeperTier tier;
  final GoalkeeperRepo repo;
  final bool sounds;

  /// Tests and the preview only: told about each shot as it's revealed.
  @visibleForTesting
  final void Function(GoalkeeperShot shot, KeeperView view)? debugOnShot;

  @override
  State<GoalkeeperMatchPage> createState() => _GoalkeeperMatchPageState();
}

class _GoalkeeperMatchPageState extends State<GoalkeeperMatchPage> with SingleTickerProviderStateMixin {
  final _scene = KeeperScene();
  final _frame = ValueNotifier(0);
  final _rng = math.Random();
  late final Ticker _ticker;
  late final PenaltySounds _sounds = PenaltySounds(enabled: widget.sounds);

  KeeperBackdrop? _backdrop;
  Size? _building;
  Size _size = Size.zero;
  CaptainArt? _art;
  ui.Image? _glove;

  _Phase _phase = _Phase.loading;
  String? _error;
  GoalkeeperRound? _round;
  GoalkeeperShot? _shot;
  final List<bool?> _results = [];
  int _saves = 0;
  GoalkeeperResult? _final;

  double _last = 0, _phaseTime = 0, _shake = 0, _tell = 0;
  bool _whistled = false;

  // The current shot.
  double _kickMs = 0, _timeScale = 1;
  ({double x, double y})? _diveAt;
  int? _diveMs;
  bool _diveSent = false;
  GoalkeeperVerdict? _verdict;
  bool _impactDone = false;
  Offset _afterVel = Offset.zero;
  double _afterT = 0;

  String? _banner;
  Color _bannerColor = Colors.white;
  int _bannerId = 0;

  int get _need => _round?.savesToWin ?? widget.tier.savesToWin;
  int get _total => _round?.shotsTotal ?? widget.tier.shotsTotal;
  int get _taken => _results.where((r) => r != null).length;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _sounds.init();
    _scene.captain
      ..setPose(CaptainPose.rig)
      ..poseBlend = 1;
    CaptainArt.shared().then((a) {
      if (mounted) setState(() => _art = a);
    }).catchError((_) {});
    loadGlove().then((g) {
      if (mounted) {
        setState(() => _glove = g);
      } else {
        g.dispose();
      }
    }).catchError((_) {});
    _start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sounds.dispose();
    _backdrop?.dispose();
    _glove?.dispose();
    super.dispose();
  }

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
        _error = f.errMessage;
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
      },
    );
  }

  void _resetForShot() {
    final s = _scene;
    s
      ..captainZ = KeeperView.spotZ + 1.9
      ..ballVisible = true
      ..trail.clear()
      ..gloveX = KeeperModel.startX
      ..gloveY = KeeperModel.startY
      ..dive = 0
      ..lean = 0
      ..tapMark = null;
    s.captain
      ..x = 0
      ..targetX = 0
      ..vx = 0;
    _kickMs = 0;
    _timeScale = 1;
    _diveAt = null;
    _diveMs = null;
    _diveSent = false;
    _verdict = null;
    _impactDone = false;
    _afterT = 0;
    _placeBallOnSpot();
  }

  void _placeBallOnSpot() {
    if (_size == Size.zero) return;
    final v = KeeperView(_size);
    _scene
      ..ballAt = v.world(0, 0.11, KeeperView.spotZ - 0.4)
      ..ballR = 0.11 * v.scaleAt(KeeperView.spotZ - 0.4);
  }

  // ---- frame loop ----------------------------------------------------------

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _last).clamp(0.0, 0.05);
    _last = now;
    final s = _scene;
    s.clock += dt;
    _phaseTime += dt;
    s.fx.update(dt);
    s.captain.update(dt);
    s.tapAge += dt;
    s.flash = math.max(0, s.flash - dt * 2.4);
    _shake *= math.exp(-dt * 9);
    s.shake = _shake < 0.2 ? Offset.zero : Offset((_rng.nextDouble() - 0.5) * _shake, (_rng.nextDouble() - 0.5) * _shake);
    final rollTarget = _phase == _Phase.flight || _phase == _Phase.after ? -s.lean * 0.07 : 0.0;
    s.roll += (rollTarget - s.roll) * math.min(1, dt * 8);

    switch (_phase) {
      case _Phase.intro:
        if (_size != Size.zero && s.ballAt == null) _placeBallOnSpot();
        if (_phaseTime > 0.8 && !_whistled) {
          _whistled = true;
          _sounds.play(PenaltySfx.whistle);
        }
        if (_phaseTime > 1.3) _nextShot();
      case _Phase.runup:
        _runup();
      case _Phase.flight:
        _flight(dt);
      case _Phase.after:
        _after(dt);
      default:
        break;
    }
    _frame.value++;
  }

  void _runup() {
    final shot = _shot!;
    final total = shot.runupMs / 1000;
    final t = (_phaseTime / total).clamp(0.0, 1.0);
    final e = Curves.easeInQuad.transform(t);
    final s = _scene;
    s.captainZ = KeeperView.spotZ + 1.9 - 1.15 * e;
    s.captain
      ..targetX = _tell * t
      ..stride += 0.25;
    if (t >= 1) _kick();
  }

  void _kick() {
    final s = _scene;
    s.captain.play(CaptainMove.foot);
    _sounds.play(PenaltySfx.kick);
    Future<void>.delayed(const Duration(milliseconds: 40), () {
      if (mounted) _sounds.play(PenaltySfx.whoosh);
    });
    _sounds.crowdLevel(0.5);
    HapticFeedback.mediumImpact();
    if (s.ballAt != null) s.fx.strike(s.ballAt!, s.ballR * 1.6, power: 0.4);
    setState(() => _phase = _Phase.flight);
    _phaseTime = 0;
    _kickMs = 0;
    // Guessed during the run-up: the dive goes now.
    if (_diveAt != null && !_diveSent) _sendDive();
  }

  void _flight(double dt) {
    final shot = _shot!;
    final s = _scene;
    // After a dive, wait for the server's verdict near the end rather than
    // show a guess. With no dive there's nothing to wait for: the keeper is
    // where he started, and the server can only agree.
    final waiting = _diveAt != null && _verdict == null && _kickMs >= shot.flightMs * 0.8;
    final target = waiting ? 0.12 : 1.0;
    _timeScale += (target - _timeScale) * math.min(1, dt * (waiting ? 14 : 8));
    _kickMs += dt * 1000 * _timeScale;
    if (_diveAt != null && _verdict == null) _kickMs = math.min(_kickMs, shot.flightMs * 0.97);

    if (_size != Size.zero) {
      final v = KeeperView(_size);
      final b = v.ballInFlight(_kickMs / shot.flightMs, shot.x, shot.y, shot.curl);
      if (s.ballAt != null) {
        s.trail.add(s.ballAt!);
        if (s.trail.length > 7) s.trail.removeAt(0);
      }
      s
        ..ballAt = b.c
        ..ballR = b.r
        ..spin += dt * 18 * _timeScale;
    }

    // The gloves follow the same reach model the server uses.
    final dive = _diveAt;
    if (dive != null) {
      final g = KeeperModel.glove(dive.x, dive.y, _diveMs, _kickMs.round());
      final dx = dive.x - KeeperModel.startX, dy = dive.y - KeeperModel.startY;
      final dist = math.sqrt(dx * dx + dy * dy);
      final moved = math.sqrt(math.pow(g.x - KeeperModel.startX, 2) + math.pow(g.y - KeeperModel.startY, 2));
      s
        ..gloveX = g.x
        ..gloveY = g.y
        ..dive = dist < 1e-6 ? 0 : (moved / dist).clamp(0.0, 1.0)
        ..lean = (dx / KeeperModel.halfWidth).clamp(-1.0, 1.0) * 0.9 * s.dive;
    }

    // Never moved: tell the server once the ball is in.
    if (!_diveSent && _kickMs >= shot.flightMs - 30) _sendDive();

    if (!_impactDone && _kickMs >= shot.flightMs) {
      final v = _verdict ?? (_diveAt == null ? _standingVerdict(shot) : null);
      if (v != null) _impact(v);
    }
  }

  void _onTap(PointerDownEvent e) {
    if (_size == Size.zero || _diveAt != null) return;
    if (_phase != _Phase.runup && _phase != _Phase.flight) return;
    final shot = _shot;
    if (shot == null || (_phase == _Phase.flight && _kickMs >= shot.flightMs - 40)) return;
    final v = KeeperView(_size);
    final g = v.toGoal(e.localPosition);
    _diveAt = (x: g.x.clamp(-KeeperModel.halfWidth - 0.3, KeeperModel.halfWidth + 0.3), y: g.y.clamp(0.0, KeeperModel.bar + 0.3));
    _diveMs = _phase == _Phase.runup ? 0 : _kickMs.round();
    _scene
      ..tapMark = e.localPosition
      ..tapAge = 0;
    HapticFeedback.selectionClick();
    if (_phase == _Phase.flight) _sendDive();
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
        return;
      }
    }
    setState(() {
      _phase = _Phase.error;
      _error = 'انقطع الاتصال أثناء التسديدة. تحقق من الاتصال ثم أعد المحاولة.';
    });
  }

  /// What the server will say about a keeper who never moved.
  GoalkeeperVerdict _standingVerdict(GoalkeeperShot shot) {
    final saved = KeeperModel.saved(shot.x, shot.y, KeeperModel.startX, KeeperModel.startY);
    final saves = _saves + (saved ? 1 : 0), taken = _taken + 1, left = _total - taken;
    return GoalkeeperVerdict(
        saved: saved, gloveX: KeeperModel.startX, gloveY: KeeperModel.startY, saves: saves, shotsTaken: taken,
        decided: left <= 0 || saves >= _need || saves + left < _need);
  }

  void _impact(GoalkeeperVerdict verdict) {
    final s = _scene;
    _impactDone = true;
    // Settle the gloves exactly where the server says they were.
    s
      ..gloveX = verdict.gloveX
      ..gloveY = verdict.gloveY
      ..dive = math.max(s.dive, 0.75);
    final idx = _shot!.number - 1;
    setState(() {
      if (idx >= 0 && idx < _results.length) _results[idx] = verdict.saved;
      _saves = verdict.saves;
    });
    final ball = s.ballAt ?? Offset.zero;
    final v = KeeperView(_size);
    final gloveC = v.goal(verdict.gloveX, verdict.gloveY);
    if (verdict.saved) {
      _sounds.play(PenaltySfx.glove);
      _sounds.play(PenaltySfx.cheer, volume: 0.7);
      HapticFeedback.heavyImpact();
      s.fx.sparks(ball, 1.3, const Color(0xffe8f6ff));
      var away = ball - gloveC;
      if (away.distance < 1) away = const Offset(0, -1);
      away = away / away.distance;
      _afterVel = Offset(away.dx * 900, -700 + away.dy * 300);
      _showBanner(_rng.nextBool() ? 'تصدّي!' : 'يا سلام!', _mint);
    } else {
      _sounds.play(PenaltySfx.net);
      _sounds.play(PenaltySfx.groan);
      HapticFeedback.mediumImpact();
      _shake = 10;
      s
        ..flash = 1
        ..flashColor = const Color(0xffff3b30);
      final dir = s.trail.isNotEmpty ? ball - s.trail.last : const Offset(0, 1);
      _afterVel = dir.distance < 1 ? const Offset(0, 600) : dir / dir.distance * 1400;
      _showBanner('هدف!', const Color(0xffff6b5f));
    }
    _sounds.crowdLevel(0.32);
    setState(() => _phase = _Phase.after);
    _phaseTime = 0;
  }

  void _after(double dt) {
    final s = _scene;
    _afterT += dt;
    final saved = _results[(_shot?.number ?? 1) - 1] ?? false;
    if (s.ballAt != null) {
      _afterVel = Offset(_afterVel.dx * math.exp(-dt * 1.5), _afterVel.dy + (saved ? 1400 : 300) * dt);
      s
        ..ballAt = s.ballAt! + _afterVel * dt
        ..ballR = s.ballR * (saved ? math.exp(-dt * 1.8) : math.exp(dt * 0.9))
        ..spin += dt * 14;
      if (s.trail.isNotEmpty) s.trail.removeAt(0);
    }
    // Gloves drift back to the middle.
    if (_afterT > 0.6) {
      s
        ..gloveX += (KeeperModel.startX - s.gloveX) * math.min(1, dt * 4)
        ..gloveY += (KeeperModel.startY - s.gloveY) * math.min(1, dt * 4)
        ..dive = math.max(0, s.dive - dt * 2)
        ..lean *= math.exp(-dt * 5);
    }
    // Move on once the server has confirmed this shot.
    if (_afterT > 1.6 && _verdict != null) {
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
        // Easy strikers give their side away a little in the run-up.
        final honesty = (1 - round.shooterSkill / 100).clamp(0.0, 1.0);
        _tell = shot.x.sign * 0.22 * honesty * honesty;
        if (_size != Size.zero) widget.debugOnShot?.call(shot, KeeperView(_size));
        setState(() => _phase = _Phase.runup);
        _phaseTime = 0;
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
    if (round == null || !mounted) return;
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
          _sounds.play(PenaltySfx.cheer);
          if (_size != Size.zero) _scene.fx.confetti(_size, count: 140);
          _scene.captain.setPose(CaptainPose.shrug);
        } else {
          _scene.captain.setPose(CaptainPose.celebrate);
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
    final first = _size == Size.zero;
    _size = size;
    if (first) _placeBallOnSpot();
    if (_backdrop?.size == size || _building == size || size.isEmpty) return;
    _building = size;
    KeeperBackdrop.build(size, MediaQuery.devicePixelRatioOf(context)).then((b) {
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
                  painter: KeeperPainter(scene: _scene, backdrop: _backdrop, art: _art, glove: _glove, repaint: _frame),
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
          if ((_phase == _Phase.runup || _phase == _Phase.intro) && _taken < 2) const _TapHint(),
          if (_phase == _Phase.finishing)
            const Positioned(bottom: 90, left: 0, right: 0, child: Center(child: CircularProgressIndicator(color: _gold))),
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
          alignment: const Alignment(0, -0.5),
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
              lostNote: 'اضغط أبكر شوية، وخلّ عينك على قدم كابتن أيوب لحظة التسديد.',
              onPlayAgain: () => Navigator.of(context).pop(true),
              onExit: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
      ),
    );
  }
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
          alignment: const Alignment(0, 0.62),
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
              child: const Text('اضغط حيث ستذهب الكرة لترتمي',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}
