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
import 'package:goal_master/features/games/data/keepy_uppy_repo.dart';

import '../penalty/penalty_painter.dart';
import '../penalty/penalty_reward_card.dart';
import '../penalty/penalty_sounds.dart';
import '../penalty/penalty_world.dart';
import 'keepy_sim.dart';

const _gold = Color(0xffffc928);
const _night = Color(0xff07110b);

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

Future<ui.Image> _loadKeeper() async {
  final data =
      await rootBundle.load('assets/images/football_keeper_strip.webp');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  return (await codec.getNextFrame()).image;
}

/// Ball on the keepy plane (z = 0, the penalty spot) for the shared painter.
V3 _ballAt(double x, double y) => V3(x, y, 0);

// ===========================================================================
// Tier picker
// ===========================================================================

class KeepyUppyPage extends StatefulWidget {
  const KeepyUppyPage({super.key, this.repo, this.sounds = true});
  final KeepyUppyRepo? repo;
  final bool sounds;

  @override
  State<KeepyUppyPage> createState() => _KeepyUppyPageState();
}

class _KeepyUppyPageState extends State<KeepyUppyPage> {
  late final KeepyUppyRepo _repo = widget.repo ?? getIt<KeepyUppyRepo>();
  KeepyStatus? _status;
  String? _error;
  Timer? _timer;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => CaptainAyoubBubble.suppressed.value++);
    _load();
  }

  @override
  void dispose() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => CaptainAyoubBubble.suppressed.value--);
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

  Future<void> _play(KeepyTier tier) async {
    HapticFeedback.selectionClick();
    var again = true;
    while (again && mounted) {
      again = await Navigator.of(context).push<bool>(MaterialPageRoute(
            builder: (_) =>
                KeepyMatchPage(tier: tier, repo: _repo, sounds: widget.sounds),
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
          expandedHeight: 260,
          backgroundColor: _night,
          foregroundColor: Colors.white,
          title: const Text('تنطيط الكرة',
              style: TextStyle(fontWeight: FontWeight.w800)),
          flexibleSpace: const FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              _JugglingPreview(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Color(0x00000000), _night],
                    stops: [0, .45, 1],
                  ),
                ),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          sliver: SliverList.list(children: [
            const Text('لا تخلّي الكرة تلمس الأرض',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text(
                'اضغط على الكرة لترفعها. كل لمسة يتحقق منها الخادم بإعادة تشغيل لعبتك كاملة.',
                style: TextStyle(color: Colors.white70, height: 1.45)),
            const SizedBox(height: 14),
            if (status != null) ...[
              _Banner(status: status, cooldown: _cooldown),
              if (status.bestTouches > 0) ...[
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.emoji_events_outlined,
                      color: _gold, size: 18),
                  const SizedBox(width: 6),
                  Text('أفضل نتيجة لك: ${status.bestTouches} لمسة',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
              ],
            ],
            const SizedBox(height: 16),
            if (_error != null)
              _ErrorBox(message: _error!, onRetry: _load)
            else if (status == null)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: _gold)),
              )
            else if (status.tiers.isEmpty)
              const _ErrorBox(message: 'لا توجد مستويات متاحة حاليًا.')
            else
              for (final tier in status.tiers) ...[
                _TierCard(
                  tier: tier,
                  onTap: tier.unlocked && status.enabled
                      ? () => _play(tier)
                      : null,
                ),
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
  final KeepyStatus status;
  final int cooldown;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String text) = !status.enabled
        ? (Icons.pause_circle_outline, Colors.white54, 'الألعاب متوقفة مؤقتًا.')
        : !status.verified
            ? (
                Icons.verified_user_outlined,
                const Color(0xfff2a93b),
                'وثّق رقم هاتفك لتدخل سحب الجوائز عند الفوز.'
              )
            : cooldown > 0
                ? (
                    Icons.timer_outlined,
                    Colors.white70,
                    'محاولتك المؤهلة القادمة بعد ${_clock(cooldown)} — يمكنك التدرّب الآن.'
                  )
                : (
                    Icons.card_giftcard_rounded,
                    _gold,
                    'محاولتك القادمة مؤهلة لسحب جائزة إذا وصلت للهدف.'
                  );
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
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, height: 1.35))),
      ]),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.tier, this.onTap});
  final KeepyTier tier;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(tier.difficulty);
    final locked = !tier.unlocked;
    final bars = (tier.ballDifficulty / 20).ceil().clamp(1, 5);
    return Material(
      color: const Color(0xff112019),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: locked ? Colors.white10 : color.withValues(alpha: .45)),
          ),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(_tierLabel(tier.difficulty),
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tier.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
              Icon(locked ? Icons.lock_rounded : Icons.play_circle_fill_rounded,
                  color: locked ? Colors.white38 : color, size: 30),
            ]),
            if (tier.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(tier.description,
                  style: const TextStyle(color: Colors.white70, height: 1.4)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.flag_rounded, size: 16, color: Colors.white54),
              const SizedBox(width: 4),
              Text('${tier.target} لمسة للفوز',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              const Text('الكرة',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 6),
              for (var i = 1; i <= 5; i++)
                Container(
                  width: 6,
                  height: 5.0 + i * 3,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: i <= bars ? color : Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ]),
            if (locked) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                    value: tier.progress.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    color: color),
              ),
              const SizedBox(height: 6),
              Text('يُفتح بعد ${tier.unlockBookings} حجوزات مكتملة',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12.5)),
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
      (Icons.touch_app_rounded, 'اضغط على الكرة وهي نازلة لترفعها من جديد.'),
      (
        Icons.swap_horiz_rounded,
        'اضغط على جانب الكرة لتدفعها للجهة الأخرى — ارجعها للوسط قبل أن تبتعد.'
      ),
      (
        Icons.center_focus_strong_rounded,
        'اللمسة في منتصف الكرة أدق وأسهل للمسة التالية.'
      ),
      (Icons.air_rounded, 'انتبه للرياح: سهم الرياح أسفل الشاشة يوضح اتجاهها.'),
      (Icons.trending_up_rounded, 'كلما زادت لمساتك، صارت الكرة أثقل وأسرع.'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xff0d1913),
          borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('كيف تلعب؟',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final (icon, text) in tips)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 19, color: _gold),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(text,
                      style:
                          const TextStyle(color: Colors.white70, height: 1.4))),
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
        decoration: BoxDecoration(
            color: const Color(0xff1d1414),
            borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة')),
          ],
        ]),
      );
}

/// The stadium with a ball juggling itself — the same physics, played by a
/// steady autopilot.
class _JugglingPreview extends StatefulWidget {
  const _JugglingPreview();
  @override
  State<_JugglingPreview> createState() => _JugglingPreviewState();
}

class _JugglingPreviewState extends State<_JugglingPreview>
    with SingleTickerProviderStateMixin {
  static const _physics = KeepyPhysics(
    hz: 120,
    target: 100000,
    gravityMm: 9000,
    kickMm: 4350,
    hitMm: 300,
    sideMm: 1700,
    jitterMm: 250,
    windMm: 0,
    rampPermille: 0,
    halfWMm: 620,
    radiusMm: 110,
    startYMm: 900,
    startVyMm: 2800,
    cooldownFrames: 9,
    maxFrames: 1 << 30,
  );
  final _scene = PenaltyScene()
    ..zoom = 1.7
    ..zoomFocus = const V3(0, 0.75, 0);
  final _frame = ValueNotifier(0);
  late final Ticker _ticker;
  KeepySim _sim = KeepySim(_physics, 7);
  double _acc = 0, _last = 0;
  int _lastTap = -100;
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
      _scene.clock += dt;
      _scene.keeper = KeeperMotion.idle(_scene.clock);
      _acc += dt;
      while (_acc >= 1 / 120) {
        _acc -= 1 / 120;
        final s = _sim;
        final taps = <KeepyTap>[];
        if (s.vy < 0 && s.y < 0.55 && s.frame - _lastTap > 14) {
          _lastTap = s.frame;
          taps.add(KeepyTap(
              s.frame,
              ((s.x + (s.x * 0.4).clamp(-0.1, 0.1)) * 1000).round(),
              (s.y * 1000).round()));
        }
        s.step(taps);
        if (s.finished) {
          _sim = KeepySim(_physics, _sim.frame + 1);
          _lastTap = -100;
        }
      }
      _scene.ball = _ballAt(_sim.x, _sim.y);
      _scene.ballSpin += dt * (6 + _sim.vx.abs() * 4);
      _scene.spinTilt = (_sim.vx * 0.35).clamp(-0.8, 0.8);
      _frame.value++;
    })
      ..start();
    _loadKeeper().then((img) {
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
    PenaltyBackdrop.build(size, MediaQuery.devicePixelRatioOf(context))
        .then((b) {
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
          painter: PenaltyPainter(
              scene: _scene,
              backdrop: _backdrop,
              keeper: _keeper,
              repaint: _frame),
        );
      });
}

// ===========================================================================
// The round
// ===========================================================================

enum _Phase { loading, countdown, playing, ended, finishing, done, error }

class _Ripple {
  _Ripple(this.at, this.hit);
  final Offset at;
  final bool hit;
  double age = 0;
}

class _Popup {
  _Popup(this.text, this.at, this.color);
  final String text;
  final Offset at;
  final Color color;
  double age = 0;
}

/// Live effects drawn over the stadium, in screen space.
class _Fx {
  final ripples = <_Ripple>[];
  final popups = <_Popup>[];
  Offset ball = Offset.zero;
  double ballRadius = 0, hitRadius = 0, ringAlpha = 0;
  double wind = 0, windMax = 0;
  bool showWind = false;
}

class _FxPainter extends CustomPainter {
  _FxPainter(this.fx, Listenable repaint) : super(repaint: repaint);
  final _Fx fx;

  @override
  void paint(Canvas canvas, Size size) {
    if (fx.ringAlpha > 0.01) {
      // The sweet spot: where a tap still reaches the ball.
      canvas.drawCircle(
          fx.ball,
          fx.hitRadius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white.withValues(alpha: 0.28 * fx.ringAlpha));
      canvas.drawCircle(fx.ball, fx.hitRadius,
          Paint()..color = Colors.white.withValues(alpha: 0.05 * fx.ringAlpha));
    }
    for (final r in fx.ripples) {
      final t = (r.age / 0.45).clamp(0.0, 1.0);
      canvas.drawCircle(
          r.at,
          12 + 34 * Curves.easeOut.transform(t),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * (1 - t) + 0.5
            ..color = (r.hit ? _gold : Colors.white)
                .withValues(alpha: (1 - t) * (r.hit ? 0.9 : 0.45)));
    }
    for (final p in fx.popups) {
      final t = (p.age / 0.9).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: p.text,
          style: TextStyle(
            color: p.color.withValues(alpha: 1 - t * t),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 6)],
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
          canvas,
          p.at.translate(-tp.width / 2,
              -tp.height / 2 - 60 * Curves.easeOut.transform(t)));
    }
    if (fx.showWind && fx.windMax > 0) {
      // Wind gauge, bottom centre: an arrow that grows with the gust.
      final c = Offset(size.width / 2, size.height - 46);
      final k = (fx.wind / fx.windMax).clamp(-1.0, 1.0);
      final bg = RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: 132, height: 30),
          const Radius.circular(15));
      canvas.drawRRect(bg, Paint()..color = const Color(0x99000000));
      final len = 46 * k.abs();
      final dir = k.sign == 0 ? 1.0 : k.sign;
      final a = c.translate(-dir * len / 2 + 14, 0),
          b = c.translate(dir * len / 2 + 14, 0);
      final paint = Paint()
        ..color = Color.lerp(Colors.white70, const Color(0xff7fd3ff), k.abs())!
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      if (len > 3) {
        canvas.drawLine(a, b, paint);
        canvas.drawLine(b, b.translate(-dir * 7, -5), paint);
        canvas.drawLine(b, b.translate(-dir * 7, 5), paint);
      } else {
        canvas.drawCircle(c.translate(14, 0), 2.5, paint);
      }
      final label = TextPainter(
        text: const TextSpan(
            text: 'رياح',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        textDirection: TextDirection.rtl,
      )..layout();
      label.paint(canvas, Offset(c.dx - 60, c.dy - label.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _FxPainter old) => false;
}

class KeepyMatchPage extends StatefulWidget {
  const KeepyMatchPage(
      {super.key,
      required this.tier,
      required this.repo,
      this.sounds = true,
      this.debugOnSim});
  final KeepyTier tier;
  final KeepyUppyRepo repo;
  final bool sounds;

  /// Tests only: hands over the live simulation so a test can play it.
  @visibleForTesting
  final void Function(KeepySim sim)? debugOnSim;

  @override
  State<KeepyMatchPage> createState() => _KeepyMatchPageState();
}

class _KeepyMatchPageState extends State<KeepyMatchPage>
    with SingleTickerProviderStateMixin {
  static const _maxTaps = 3000;

  final _scene = PenaltyScene();
  final _fx = _Fx();
  final _frame = ValueNotifier(0);
  final _rng = math.Random();
  late final Ticker _ticker;
  late final PenaltySounds _sounds = PenaltySounds(enabled: widget.sounds);

  PenaltyBackdrop? _backdrop;
  Size? _building;
  Size _size = Size.zero;
  ui.Image? _keeperImage;

  _Phase _phase = _Phase.loading;
  String? _error;
  KeepyRound? _round;
  KeepySim? _sim;
  final _taps = <KeepyTap>[];
  KeepyResult? _result;

  double _last = 0, _acc = 0, _phaseTime = 0, _shake = 0, _celebrate = 0;
  double _prevX = 0, _prevY = 0;
  int _touches = 0, _counterPop = 0, _countdownShown = -1;
  String? _banner;
  Color _bannerColor = Colors.white;
  int _bannerId = 0;

  int get _target => _round?.physics.target ?? widget.tier.target;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _sounds.init();
    _loadKeeper().then((img) {
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
        _sim = KeepySim(round.physics, round.seed);
        widget.debugOnSim?.call(_sim!);
        _taps.clear();
        _touches = 0;
        _scene
          ..ball = _ballAt(0, round.physics.ballRadius)
          ..trail.clear()
          ..boardMessage = null;
        _fx
          ..windMax = round.physics.windMm / 1000.0
          ..showWind = round.physics.windMm > 0;
        setState(() => _phase = _Phase.countdown);
        _phaseTime = 0;
        _countdownShown = -1;
      },
    );
  }

  // ---- frame loop ----------------------------------------------------------

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _last).clamp(0.0, 0.1);
    _last = now;
    final s = _scene;
    s.clock += dt;
    _phaseTime += dt;
    s.keeper = KeeperMotion.idle(s.clock);

    s.flash = math.max(0, s.flash - dt * 2.2);
    _shake *= math.exp(-dt * 9);
    s.shake = _shake < 0.2
        ? Offset.zero
        : Offset((_rng.nextDouble() - 0.5) * _shake,
            (_rng.nextDouble() - 0.5) * _shake);
    if (_celebrate > 0) {
      _celebrate = math.max(0, _celebrate - dt * 0.3);
      s.crowdJump =
          (math.sin(s.clock * 11).abs() * 3.2) * math.min(1, _celebrate * 2);
      if (_rng.nextDouble() < 0.25) s.flashSeed = _rng.nextInt(1 << 30);
    } else {
      s.crowdJump = 0;
    }
    for (final r in _fx.ripples) {
      r.age += dt;
    }
    _fx.ripples.removeWhere((r) => r.age > 0.45);
    for (final p in _fx.popups) {
      p.age += dt;
    }
    _fx.popups.removeWhere((p) => p.age > 0.9);

    switch (_phase) {
      case _Phase.countdown:
        _countdown();
      case _Phase.playing:
        _play(dt);
      default:
        break;
    }
    _updateBallFx(dt);
    _frame.value++;
  }

  void _countdown() {
    final sim = _sim!;
    final n = 3 - _phaseTime.floor();
    if (n != _countdownShown && n >= 1) {
      _countdownShown = n;
      _showBanner('$n', Colors.white);
      HapticFeedback.selectionClick();
    }
    final r = sim.p.ballRadius;
    if (_phaseTime >= 3.0) {
      // The flick-up: from the grass to where the physics starts.
      final t = ((_phaseTime - 3.0) / 0.22).clamp(0.0, 1.0);
      final e = Curves.easeOutCubic.transform(t);
      _scene.ball = _ballAt(0, r + (sim.y - r) * e);
      _scene.ballSpin += 0.2;
      if (t >= 1) {
        _sounds.play(PenaltySfx.whistle);
        _prevX = sim.x;
        _prevY = sim.y;
        _acc = 0;
        setState(() {
          _phase = _Phase.playing;
          _banner = null;
        });
      }
    } else {
      _scene.ball = _ballAt(0, r);
    }
  }

  void _play(double dt) {
    final sim = _sim!;
    const step = 1 / 120;
    _acc += dt;
    while (_acc >= step && !sim.finished) {
      _acc -= step;
      _prevX = sim.x;
      _prevY = sim.y;
      final i = sim.frame;
      final taps = [
        for (final t in _taps.reversed.takeWhile((t) => t.frame >= i))
          if (t.frame == i) t
      ].reversed.toList();
      final e = sim.step(taps);
      switch (e) {
        case KeepyEvent.touch:
          _onTouch();
        case KeepyEvent.won:
          _onTouch();
          _onWon();
        case KeepyEvent.lost:
          _onLost();
        case KeepyEvent.wall:
          HapticFeedback.selectionClick();
        case KeepyEvent.none:
          break;
      }
    }
    final a = sim.finished ? 1.0 : (_acc / step).clamp(0.0, 1.0);
    final x = _prevX + (sim.x - _prevX) * a;
    final y = math.max(sim.p.ballRadius, _prevY + (sim.y - _prevY) * a);
    _scene.ball = _ballAt(x, y);
    _scene.ballSpin += dt * (5 + sim.vx.abs() * 6 + sim.vy.abs() * 1.5);
    _scene.spinTilt += ((sim.vx * 0.35).clamp(-0.9, 0.9) - _scene.spinTilt) *
        math.min(1, dt * 6);
    _fx.wind = sim.wind;
  }

  void _updateBallFx(double dt) {
    if (_size == Size.zero) return;
    final cam = PenaltyCamera(_size);
    final b = _scene.ball;
    _fx.ball = cam.project(b);
    final scale = cam.scaleAt(b.z);
    _fx.ballRadius = Pitch.ballRadius * scale;
    _fx.hitRadius = (_round?.physics.hitRadius ?? 0.25) * scale;
    final sim = _sim;
    final guided = widget.tier.ballDifficulty <= 50 || _touches < 3;
    final want = _phase == _Phase.playing && sim != null && sim.vy < 0 && guided
        ? 1.0
        : 0.0;
    _fx.ringAlpha += (want - _fx.ringAlpha) * math.min(1, dt * 10);

    final speed =
        sim == null ? 0.0 : math.sqrt(sim.vx * sim.vx + sim.vy * sim.vy);
    if (_phase == _Phase.playing && speed > 3.2) {
      _scene.trail.add(_fx.ball);
      if (_scene.trail.length > 4) _scene.trail.removeAt(0);
    } else if (_scene.trail.isNotEmpty) {
      _scene.trail.removeAt(0);
    }
  }

  void _onTap(PointerDownEvent e) {
    if (_phase != _Phase.playing || _size == Size.zero) return;
    final sim = _sim!;
    if (sim.finished || _taps.length >= _maxTaps) return;
    final w = PenaltyCamera(_size).onPlane(e.localPosition, 0);
    final tap = KeepyTap(sim.frame, (w.x * 1000).round(), (w.y * 1000).round());
    _taps.add(tap);
    // Preview the verdict for the ripple colour only; the step decides.
    final dx = sim.x - tap.xMm / 1000.0, dy = sim.y - tap.yMm / 1000.0;
    final r = sim.p.hitRadius;
    _fx.ripples.add(_Ripple(e.localPosition, dx * dx + dy * dy <= r * r));
  }

  void _onTouch() {
    final sim = _sim!;
    _touches = sim.touches;
    _counterPop++;
    _sounds.play(PenaltySfx.kick);
    HapticFeedback.lightImpact();
    if (sim.lastOffset.abs() < 0.18) {
      _fx.popups
          .add(_Popup('مثالي!', _fx.ball.translate(0, -_fx.ballRadius), _gold));
    }
    if (_touches % 5 == 0 && _touches < _target) {
      _scene.boardMessage = '×$_touches';
      _celebrate = math.max(_celebrate, 0.45);
      _sounds.crowdLevel(0.55);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && _phase == _Phase.playing) {
          _scene.boardMessage = null;
          _sounds.crowdLevel(0.32);
        }
      });
    }
    if (mounted) setState(() {});
  }

  void _onWon() {
    _celebrate = 1.4;
    _scene
      ..flash = 1
      ..boardMessage = 'GOAL MASTER';
    _sounds.play(PenaltySfx.cheer);
    HapticFeedback.heavyImpact();
    _showBanner('أسطوري!', _gold);
    setState(() => _phase = _Phase.ended);
    Future.delayed(const Duration(milliseconds: 1700), _finish);
  }

  void _onLost() {
    final sim = _sim!;
    _scene.ball = _ballAt(sim.x, sim.p.ballRadius);
    _shake = 7;
    _sounds.play(PenaltySfx.groan);
    HapticFeedback.mediumImpact();
    _showBanner(_touches == 0 ? 'سقطت الكرة' : '$_touches لمسة',
        const Color(0xffff8a65));
    setState(() => _phase = _Phase.ended);
    Future.delayed(const Duration(milliseconds: 1300), _finish);
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
      if (attempt > 0)
        await Future<void>.delayed(Duration(milliseconds: 700 * attempt));
      final res = await widget.repo.finish(round.id, _taps);
      if (!mounted) return;
      final ok = res.fold((_) => null, (r) => r);
      if (ok != null) {
        setState(() {
          _result = ok;
          _phase = _Phase.done;
        });
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
    if (_phase != _Phase.playing && _phase != _Phase.countdown) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الخروج من الجولة؟'),
        content: const Text('ستنتهي الجولة الحالية ولن تُحتسب.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('متابعة اللعب')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('خروج')),
        ],
      ),
    );
    return leave ?? false;
  }

  void _ensureBackdrop(Size size) {
    _size = size;
    if (_backdrop?.size == size || _building == size || size.isEmpty) return;
    _building = size;
    PenaltyBackdrop.build(size, MediaQuery.devicePixelRatioOf(context))
        .then((b) {
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
        if (await _confirmLeave() && context.mounted)
          Navigator.of(context).pop(false);
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
                child: Stack(fit: StackFit.expand, children: [
                  CustomPaint(
                    size: box.biggest,
                    painter: PenaltyPainter(
                        scene: _scene,
                        backdrop: _backdrop,
                        keeper: _keeperImage,
                        repaint: _frame),
                  ),
                  CustomPaint(
                      size: box.biggest, painter: _FxPainter(_fx, _frame)),
                ]),
              );
            }),
          ),
          if (_backdrop == null)
            const Positioned.fill(
                child: IgnorePointer(
              child: ColoredBox(
                  color: _night,
                  child:
                      Center(child: CircularProgressIndicator(color: _gold))),
            )),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(bottom: false, child: _hud())),
          if (_banner != null) _bannerWidget(),
          if (_phase == _Phase.countdown) const _TapHint(),
          if (_phase == _Phase.finishing)
            const Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: Center(child: CircularProgressIndicator(color: _gold)),
            ),
          if (_phase == _Phase.error) _errorOverlay(),
          if (_phase == _Phase.done && _result != null) _resultOverlay(),
        ]),
      ),
    );
  }

  Widget _hud() {
    final color = _tierColor(widget.tier.difficulty);
    final progress = (_touches / _target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _GlassButton(
          icon: Icons.close_rounded,
          onTap: () async {
            if (await _confirmLeave() && mounted)
              Navigator.of(context).pop(false);
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xcc07110b),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(_tierLabel(widget.tier.difficulty),
                      style: TextStyle(
                          color: color,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800)),
                ),
                const Spacer(),
                TweenAnimationBuilder<double>(
                  key: ValueKey(_counterPop),
                  tween: Tween(begin: 1.45, end: 1),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  builder: (context, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Text('$_touches',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1)),
                ),
                Text(' / $_target',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                if (_round?.rewardEligible == true)
                  const Icon(Icons.card_giftcard_rounded,
                      color: _gold, size: 18)
                else
                  const SizedBox(width: 18),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    color: Color.lerp(color, _gold, v),
                  ),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        _GlassButton(
          icon: PenaltySounds.muted
              ? Icons.volume_off_rounded
              : Icons.volume_up_rounded,
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
            builder: (context, v, child) =>
                Transform.scale(scale: 0.4 + 0.6 * v, child: child),
            child: Text(
              _banner!,
              style: TextStyle(
                color: _bannerColor,
                fontSize: 54,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 18),
                  Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 3),
                      blurRadius: 2),
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
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white70, size: 44),
                const SizedBox(height: 12),
                Text(_error ?? 'حدث خطأ غير متوقع.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('رجوع',
                          style: TextStyle(color: Colors.white70))),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: _gold, foregroundColor: Colors.black),
                    onPressed: _sim?.finished == true ? _finish : _start,
                    child: const Text('إعادة المحاولة'),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      );

  Widget _resultOverlay() {
    final r = _result!;
    final summary = r.rejected
        ? 'لم نتمكن من التحقق من هذه الجولة.'
        : r.prize.won
            ? 'وصلت إلى ${r.touches} لمسة متتالية${r.newBest ? ' — رقم قياسي جديد!' : ''}'
            : '${r.touches} لمسة — كنت تحتاج ${r.target}${r.newBest && r.touches > 0 ? ' (رقمك القياسي الجديد)' : ''}';
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => ColoredBox(
          color: Colors.black.withValues(alpha: 0.55 * v),
          child: Opacity(
              opacity: v,
              child: Transform.translate(
                  offset: Offset(0, 40 * (1 - v)), child: child)),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: PenaltyResultPanel(
              result: r.prize,
              goalsToWin: r.target,
              kicksTaken: r.touches,
              summary: summary,
              lostNote: r.rejected
                  ? 'إذا تكرر هذا، حدّث التطبيق أو تواصل معنا.'
                  : 'المس الكرة وهي نازلة وقريبة من منتصفها، وأرجعها للوسط قبل أن تبتعد.',
              onPlayAgain: () => Navigator.of(context).pop(true),
              onExit: () => Navigator.of(context).pop(false),
            ),
          ),
        ),
      ),
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
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 22)),
        ),
      );
}

class _TapHint extends StatefulWidget {
  const _TapHint();
  @override
  State<_TapHint> createState() => _TapHintState();
}

class _TapHintState extends State<_TapHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Align(
          alignment: const Alignment(0, 0.93),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) =>
                  Transform.scale(scale: 0.9 + 0.15 * _c.value, child: child),
              child: const Icon(Icons.touch_app_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('اضغط على الكرة وهي نازلة',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}
