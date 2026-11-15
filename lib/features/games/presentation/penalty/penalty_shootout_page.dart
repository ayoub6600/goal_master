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
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';

import 'penalty_painter.dart';
import 'penalty_reward_card.dart';
import 'penalty_sounds.dart';
import 'penalty_world.dart';

const _gold = Color(0xffffc928);
const _night = Color(0xff07110b);

String _tierLabel(String difficulty) => switch (difficulty) {
      'easy' => 'سهل',
      'medium' => 'متوسط',
      'hard' => 'صعب',
      _ => difficulty,
    };

Color _tierColor(String difficulty) => switch (difficulty) {
      'easy' => const Color(0xff4cc26a),
      'medium' => const Color(0xfff2a93b),
      _ => const Color(0xffe8534a),
    };

int _tierRank(String difficulty) => switch (difficulty) {
      'easy' => 1,
      'medium' => 2,
      _ => 3,
    };

/// How far a strike strays from where it was aimed, by tier.
double _executionSpread(String difficulty) => switch (difficulty) {
      'easy' => 0.008,
      'medium' => 0.018,
      _ => 0.028,
    };

String _uuid() {
  final r = math.Random.secure();
  String hex(int n) => List.generate(n, (_) => r.nextInt(16).toRadixString(16)).join();
  return '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + r.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
}

Future<ui.Image> _loadKeeper() async {
  final data = await rootBundle.load('assets/images/football_keeper_strip.webp');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  return (await codec.getNextFrame()).image;
}

// ===========================================================================
// Tier picker
// ===========================================================================

class PenaltyShootoutPage extends StatefulWidget {
  const PenaltyShootoutPage({super.key, this.repo, this.sounds = true});
  final PenaltyShootoutRepo? repo;
  final bool sounds;

  @override
  State<PenaltyShootoutPage> createState() => _PenaltyShootoutPageState();
}

class _PenaltyShootoutPageState extends State<PenaltyShootoutPage> {
  late final PenaltyShootoutRepo _repo = widget.repo ?? getIt<PenaltyShootoutRepo>();
  PenaltyStatus? _status;
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
          if (!mounted) return;
          setState(() => _cooldown = math.max(0, _cooldown - 1));
        });
      }
    });
  }

  Future<void> _play(PenaltyTier tier) async {
    HapticFeedback.selectionClick();
    var again = true;
    while (again && mounted) {
      again = await Navigator.of(context).push<bool>(MaterialPageRoute(
            builder: (_) => PenaltyMatchPage(tier: tier, repo: _repo, sounds: widget.sounds),
          )) ??
          false;
    }
    if (mounted) _load();
  }

  /// The wait is admin-set and can be days long: "2 يوم و 05:12:09".
  String _clock(int s) {
    final days = s ~/ 86400;
    final rest = s % 86400;
    final hms =
        '${(rest ~/ 3600).toString().padLeft(2, '0')}:${(rest % 3600 ~/ 60).toString().padLeft(2, '0')}:${(rest % 60).toString().padLeft(2, '0')}';
    return days > 0 ? '$days يوم و $hms' : hms;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return Scaffold(
      backgroundColor: _night,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 250,
          backgroundColor: _night,
          foregroundColor: Colors.white,
          title: const Text('ركلات الترجيح', style: TextStyle(fontWeight: FontWeight.w800)),
          flexibleSpace: const FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              _StadiumPreview(),
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
            const Text('واجه الحارس من نقطة الجزاء',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('اسحب من الكرة نحو المكان الذي تريده في المرمى. كل ركلة يحسمها الخادم لحظة التسديد.',
                style: TextStyle(color: Colors.white70, height: 1.45)),
            const SizedBox(height: 14),
            if (status != null) _EligibilityBanner(status: status, cooldown: _cooldown, clock: _clock),
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
                  enabled: status.enabled,
                  onTap: tier.unlocked && status.enabled ? () => _play(tier) : null,
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

class _EligibilityBanner extends StatelessWidget {
  const _EligibilityBanner({required this.status, required this.cooldown, required this.clock});
  final PenaltyStatus status;
  final int cooldown;
  final String Function(int) clock;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, String text) = !status.enabled
        ? (Icons.pause_circle_outline, Colors.white54, 'الألعاب متوقفة مؤقتًا.')
        : !status.verified
            ? (Icons.verified_user_outlined, const Color(0xfff2a93b), 'وثّق رقم هاتفك لتدخل سحب الجوائز عند الفوز.')
            : cooldown > 0
                ? (Icons.timer_outlined, Colors.white70, 'محاولتك المؤهلة القادمة بعد ${clock(cooldown)} — يمكنك التدرّب الآن.')
                : (Icons.card_giftcard_rounded, _gold, 'محاولتك القادمة مؤهلة لسحب جائزة إذا فزت.');
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
  const _TierCard({required this.tier, required this.enabled, this.onTap});
  final PenaltyTier tier;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(tier.difficulty);
    final locked = !tier.unlocked;
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
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              Icon(locked ? Icons.lock_rounded : Icons.play_circle_fill_rounded,
                  color: locked ? Colors.white38 : color, size: 30),
            ]),
            if (tier.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(tier.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
            ],
            const SizedBox(height: 12),
            Row(children: [
              _Stat(icon: Icons.sports_soccer, text: '${tier.kicksTotal} ركلات'),
              const SizedBox(width: 14),
              _Stat(icon: Icons.flag_rounded, text: '${tier.goalsToWin} أهداف للفوز'),
              const Spacer(),
              const Text('الحارس', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 6),
              for (var i = 1; i <= 3; i++)
                Container(
                  width: 7,
                  height: 6.0 + i * 4,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: i <= _tierRank(tier.difficulty) ? color : Colors.white12,
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
                  color: color,
                ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ]);
}

class _HowToPlay extends StatelessWidget {
  const _HowToPlay();

  @override
  Widget build(BuildContext context) {
    const tips = [
      (Icons.swipe_up_rounded, 'اسحب من الكرة نحو النقطة التي تريدها داخل المرمى.'),
      (Icons.crop_free_rounded, 'الزوايا أصعب على الحارس، لكن الخطأ البسيط قد يرتطم بالقائم أو يخرج.'),
      (Icons.bolt_rounded, 'السحب السريع يعطي تسديدة أقوى وأسرع… وأقل دقة.'),
      (Icons.gesture_rounded, 'اسحب بانحناءة لتلتف الكرة في الهواء.'),
      (Icons.shield_rounded, 'في المستويات الأعلى يقرأ الحارس اتجاهك أكثر ويصل أبعد.'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xff0d1913), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('كيف تسجّل؟',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
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

/// The real stadium, small, with the keeper swaying on his line.
class _StadiumPreview extends StatefulWidget {
  const _StadiumPreview();
  @override
  State<_StadiumPreview> createState() => _StadiumPreviewState();
}

class _StadiumPreviewState extends State<_StadiumPreview> with SingleTickerProviderStateMixin {
  final _scene = PenaltyScene();
  final _frame = ValueNotifier(0);
  late final Ticker _ticker;
  PenaltyBackdrop? _backdrop;
  Size? _building;
  ui.Image? _keeper;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _scene.clock = elapsed.inMicroseconds / 1e6;
      _scene.keeper = KeeperMotion.idle(_scene.clock);
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

enum _Phase { loading, intro, aiming, flying, aftermath, replay, finishing, done, error }

class PenaltyMatchPage extends StatefulWidget {
  const PenaltyMatchPage({super.key, required this.tier, required this.repo, this.sounds = true});
  final PenaltyTier tier;
  final PenaltyShootoutRepo repo;
  final bool sounds;

  @override
  State<PenaltyMatchPage> createState() => _PenaltyMatchPageState();
}

class _PenaltyMatchPageState extends State<PenaltyMatchPage> with SingleTickerProviderStateMixin {
  final _scene = PenaltyScene();
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
  PenaltyAttempt? _attempt;
  final List<bool?> _kicks = [];
  int _goals = 0;
  PenaltyResult? _final;

  // Current kick.
  BallFlight? _flight;
  KeeperMotion? _keeper;
  PenaltyKickResult? _result;
  String? _eventId;
  ShotAim? _sentAim;
  bool _sendFailed = false;
  double _kickT = 0, _timeScale = 1, _frozenClock = 0;

  /// The boot swings in for [_windup] seconds before contact, then the
  /// world holds still for a beat ([_hitStop]) as the ball leaves.
  double _windup = 0, _hitStop = 0, _shotPower = 0.5;
  bool _decisive = false;

  double _last = 0, _phaseTime = 0, _shake = 0, _celebrate = 0;
  bool _whistled = false;
  final List<SwipeSample> _swipe = [];
  final _stopwatch = Stopwatch()..start();
  String? _banner;
  Color _bannerColor = Colors.white;
  int _bannerId = 0;

  int get _kickIndex => _kicks.where((k) => k != null).length;
  int get _total => _attempt?.kicksTotal ?? widget.tier.kicksTotal;
  int get _need => _attempt?.goalsToWin ?? widget.tier.goalsToWin;
  bool get _decided => _goals >= _need || _goals + (_total - _kickIndex) < _need;

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
    res.fold((f) => setState(() {
          _phase = _Phase.error;
          _error = f.errMessage;
        }), (a) {
      setState(() {
        _attempt = a;
        _goals = a.goalsScored;
        _kicks
          ..clear()
          ..addAll(List<bool?>.filled(a.kicksTotal, null));
        // Resuming: we know the score, not the order, so show goals first.
        for (var i = 0; i < a.kicksTaken; i++) {
          _kicks[i] = i < a.goalsScored;
        }
      });
      if (_decided || _kickIndex >= _total) {
        _finish();
      } else {
        _enterIntro();
      }
    });
  }

  void _enterIntro() {
    _resetBall();
    final left = _total - _kickIndex;
    // This kick settles it either way: score and you've won, or miss and
    // you're out.
    _decisive = _kickIndex > 0 && (_goals + 1 >= _need || _goals + left - 1 < _need) && _goals + left >= _need;
    setState(() {
      _phase = _Phase.intro;
      _banner = null;
    });
    if (_decisive) {
      _showBanner('ركلة حاسمة!', _gold);
      _sounds.crowdLevel(0.5);
    }
    _phaseTime = 0;
    _whistled = false;
  }

  void _resetBall() {
    _scene
      ..ball = Pitch.ballSpot
      ..trail.clear()
      ..ripple = null
      ..boardMessage = null
      ..zoom = 1
      ..guide = const []
      ..guideReach = 0
      ..reticle = null;
    _flight = null;
    _keeper = null;
    _result = null;
    _sentAim = null;
    _eventId = null;
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
    final tensionTarget = _decisive && (_phase == _Phase.intro || _phase == _Phase.aiming) ? 1.0 : 0.0;
    s.tension += (tensionTarget - s.tension) * math.min(1, dt * 3);
    _shake *= math.exp(-dt * 9);
    s.shake = _shake < 0.2
        ? Offset.zero
        : Offset((_rng.nextDouble() - 0.5) * _shake, (_rng.nextDouble() - 0.5) * _shake);
    if (_celebrate > 0) {
      _celebrate = math.max(0, _celebrate - dt * 0.3);
      s.crowdJump = (math.sin(s.clock * 11).abs() * 3.2) * math.min(1, _celebrate * 2);
      if (_rng.nextDouble() < 0.25) s.flashSeed = _rng.nextInt(1 << 30);
    } else {
      s.crowdJump = 0;
    }
    s.letterbox = _phase == _Phase.replay
        ? math.min(1, s.letterbox + dt * 4)
        : math.max(0, s.letterbox - dt * 4);

    switch (_phase) {
      case _Phase.intro:
        s.keeper = KeeperMotion.idle(s.clock);
        if (_phaseTime > 0.7 && !_whistled) {
          _whistled = true;
          _sounds.play(PenaltySfx.whistle);
        }
        if (_phaseTime > 1.15) setState(() => _phase = _Phase.aiming);
      case _Phase.flying:
      case _Phase.aftermath:
      case _Phase.replay:
        _advanceKick(dt);
      default:
        s.keeper = KeeperMotion.idle(s.clock);
    }
    _frame.value++;
  }

  void _advanceKick(double dt) {
    final f = _flight!;
    final s = _scene;
    final replay = _phase == _Phase.replay;
    if (!replay && _windup > 0) {
      // Boot swinging in: the camera leans back, then snaps on contact.
      _windup -= dt;
      s.zoom = 1 - 0.035 * (1 - (_windup / 0.12).clamp(0.0, 1.0));
      s.keeper = KeeperMotion.idle(_frozenClock);
      if (_windup <= 0) _contact();
      return;
    }
    if (!replay && _hitStop > 0) {
      _hitStop -= dt;
      return;
    }
    final waiting = _result == null && _kickT >= f.duration * 0.16;
    final target = replay ? 0.36 : (waiting ? 0.1 : 1.0);
    _timeScale += (target - _timeScale) * math.min(1, dt * (waiting ? 12 : 7));
    final prev = _kickT;
    _kickT += dt * _timeScale;
    // Never let the ball reach the keeper before the server has spoken.
    if (_result == null) _kickT = math.min(_kickT, f.duration * 0.62);

    s.keeper = _keeper?.at(_kickT, _frozenClock) ?? KeeperMotion.idle(_frozenClock);
    var ball = f.at(_kickT);
    if (f.caught && _kickT >= f.duration) {
      final k = s.keeper.centre;
      ball = V3(k.x, k.y + 0.05, k.z - 0.3);
    }
    if (_size != Size.zero && _kickT < f.duration + 0.25) {
      s.trail.add(PenaltyCamera(_size).project(s.ball));
      if (s.trail.length > 12) s.trail.removeAt(0);
    } else {
      s.trail.clear();
    }
    s.ball = ball;
    s.ballSpin += dt * _timeScale * (_kickT < f.duration ? 30 : 8);
    s.spinTilt = f.curl * 0.6;
    s.netClock = _kickT;

    if (replay) {
      s.zoom += (1.5 - s.zoom) * math.min(1, dt * 3);
      s.zoomFocus = V3(f.target.x * 0.8, 0.5 + f.target.y * 0.4, Pitch.goalLineZ);
    } else {
      // Punched in at contact, easing back as the ball flies.
      s.zoom += (1 - s.zoom) * math.min(1, dt * 5);
    }

    if (prev < f.duration && _kickT >= f.duration && f.outcome != null) {
      _impact(replay: replay);
    }

    if (_phase == _Phase.flying && _kickT >= f.duration) {
      setState(() => _phase = _Phase.aftermath);
    } else if (_phase == _Phase.aftermath && _kickT >= f.duration + 1.75) {
      if (f.outcome == KickOutcome.miss) {
        _nextKick();
      } else {
        _startReplay();
      }
    } else if (replay && _kickT >= f.duration + 0.95) {
      _nextKick();
    }
  }

  /// Boot meets ball: the sound, the jolt and the debris all land together.
  void _contact() {
    final s = _scene;
    _sounds.play(PenaltySfx.kick);
    Future<void>.delayed(const Duration(milliseconds: 45), () {
      if (mounted) _sounds.play(PenaltySfx.whoosh);
    });
    _sounds.crowdLevel(0.55);
    HapticFeedback.heavyImpact();
    _hitStop = 0.045 + 0.03 * _shotPower;
    _shake = 5 + 7 * _shotPower;
    s
      ..zoom = 1.06 + 0.04 * _shotPower
      ..squash = 1
      ..speed = 0.55 + 0.45 * _shotPower;
    if (_size != Size.zero) {
      final cam = PenaltyCamera(_size);
      s.fx.strike(cam.project(Pitch.ballSpot), Pitch.ballRadius * cam.scaleAt(0), power: _shotPower);
    }
  }

  void _impact({required bool replay}) {
    final f = _flight!;
    final hit = f.at(f.duration);
    switch (f.outcome!) {
      case KickOutcome.goal:
        _scene.ripple = NetRipple(V3(hit.x, hit.y, 0), f.duration + 0.04, 0.5);
        _sounds.play(PenaltySfx.net);
        if (!replay) {
          _sounds.play(PenaltySfx.cheer);
          _celebrate = 1;
          _shake = 7;
          _burst(hit, Colors.white, 0.8);
          if (_size != Size.zero) _scene.fx.confetti(_size);
          _scene
            ..flash = 1
            ..boardMessage = 'GOAL!';
          HapticFeedback.heavyImpact();
          _showBanner('هدف!', _gold);
        }
      case KickOutcome.save:
        _sounds.play(PenaltySfx.glove);
        _burst(_scene.ball, const Color(0xffe8f6ff), 1);
        if (!replay) {
          _sounds.play(PenaltySfx.groan);
          HapticFeedback.mediumImpact();
          _showBanner(f.caught ? 'أمسكها الحارس!' : 'تصدّى الحارس!', const Color(0xff7fd3ff));
        }
      case KickOutcome.post:
        _sounds.play(PenaltySfx.post);
        _shake = 11;
        _burst(hit, const Color(0xffffc46b), 1.2);
        if (!replay) {
          _sounds.play(PenaltySfx.groan);
          HapticFeedback.heavyImpact();
          final bar = (f.aim.y - 1).abs() <= Pitch.woodworkBand;
          _showBanner(bar ? 'العارضة!' : 'القائم!', const Color(0xffff8a65));
        }
      case KickOutcome.miss:
        if (!replay) {
          _sounds.play(PenaltySfx.groan);
          HapticFeedback.lightImpact();
          _showBanner('خارج المرمى', const Color(0xffff6b5f));
        }
    }
    if (!replay) _reveal();
    _sounds.crowdLevel(0.32);
  }

  void _burst(V3 at, Color color, double scale) {
    if (_size == Size.zero) return;
    final cam = PenaltyCamera(_size);
    _scene.fx.sparks(cam.project(at), scale * (cam.scaleAt(at.z) / 40).clamp(0.6, 1.6), color);
  }

  void _reveal() {
    final r = _result!;
    setState(() {
      _kicks[r.kicksTaken - 1] = r.scored;
      for (var i = 0; i < r.kicksTaken - 1; i++) {
        _kicks[i] ??= false;
      }
      _goals = r.goalsScored;
    });
  }

  void _showBanner(String text, Color color) => setState(() {
        _banner = text;
        _bannerColor = color;
        _bannerId++;
      });

  void _startReplay() {
    setState(() {
      _phase = _Phase.replay;
      _banner = null;
    });
    _kickT = 0;
    _timeScale = 0.36;
    _scene
      ..ripple = null
      ..boardMessage = null
      ..trail.clear();
  }

  void _skip() {
    if (_phase == _Phase.aftermath && _kickT > (_flight?.duration ?? 0) + 0.5) {
      _nextKick();
    } else if (_phase == _Phase.replay) {
      _nextKick();
    }
  }

  void _nextKick() {
    _scene.zoom = 1;
    if (_decided || _kickIndex >= _total) {
      _resetBall();
      _finish();
    } else {
      _enterIntro();
    }
  }

  // ---- shooting ------------------------------------------------------------

  void _onPanStart(DragStartDetails d) {
    if (_phase != _Phase.aiming) return;
    _swipe
      ..clear()
      ..add(SwipeSample(d.localPosition, _stopwatch.elapsedMilliseconds));
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_phase != _Phase.aiming || _swipe.isEmpty) return;
    _swipe.add(SwipeSample(d.localPosition, _stopwatch.elapsedMilliseconds));
    _updateGuide();
    final shot = SwipeReader.read(_swipe, PenaltyCamera(_size));
    _scene.power = shot == null ? 0 : shot.power;
  }

  void _updateGuide() {
    final reach = switch (widget.tier.difficulty) { 'easy' => 1.0, 'medium' => 0.45, _ => 0.0 };
    final shot = reach > 0 ? SwipeReader.read(_swipe, PenaltyCamera(_size)) : null;
    if (shot == null) {
      _scene
        ..guide = const []
        ..reticle = null;
      return;
    }
    final preview = BallFlight(aim: shot.aim, curl: shot.curl, duration: 0.6);
    _scene
      ..guide = [for (var i = 1; i <= 16; i++) preview.at(0.6 * i / 16)]
      ..guideReach = reach
      ..reticle = shot.aim;
  }

  void _onPanEnd(DragEndDetails d) {
    if (_phase != _Phase.aiming || _swipe.isEmpty) return;
    _scene
      ..guide = const []
      ..reticle = null
      ..power = -1;
    final shot = SwipeReader.read(_swipe, PenaltyCamera(_size));
    _swipe.clear();
    if (shot == null) return;
    _shotPower = shot.power;
    _windup = 0.12;
    _hitStop = 0;

    final raw = SwipeReader.withExecutionError(shot, _executionSpread(widget.tier.difficulty), _rng);
    // Rounded exactly as sent, so the client animates the shot the server judges.
    final aim = ShotAim(double.parse(raw.x.toStringAsFixed(4)), double.parse(raw.y.toStringAsFixed(4)));
    _flight = BallFlight(aim: aim, curl: shot.curl, duration: shot.flightSeconds);
    _sentAim = aim;
    _eventId = _uuid();
    _kickT = 0;
    _timeScale = 1;
    _frozenClock = _scene.clock;
    setState(() {
      _phase = _Phase.flying;
      _banner = null;
    });
    HapticFeedback.selectionClick();
    _send();
  }

  Future<void> _send() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
      if (!mounted || _attempt == null || _eventId == null) return;
      final res = await widget.repo.kick(
          attemptId: _attempt!.id, eventId: _eventId!, aimX: _sentAim!.x, aimY: _sentAim!.y);
      if (!mounted) return;
      final ok = res.fold((_) => null, (r) => r);
      if (ok != null) {
        _onResult(ok);
        return;
      }
    }
    setState(() => _sendFailed = true);
  }

  void _onResult(PenaltyKickResult r) {
    final f = _flight;
    if (f == null || _result != null) return;
    _result = r;
    _sendFailed = false;
    f.outcome = outcomeFrom(r.outcome);

    final startX = KeeperMotion.idleX(_frozenClock);
    final hit = f.target;
    final react = math.max(_kickT + 0.02, f.duration * 0.14);
    final shotZone = f.aim.zone;
    late V3 glove;
    var arrive = f.duration;
    switch (f.outcome!) {
      case KickOutcome.save:
        glove = V3(hit.x, math.max(0.25, hit.y), hit.z);
        f.parrySide = hit.x >= startX ? 1 : -1;
        f.caught = (hit.x - startX).abs() < 1.0 && hit.y < 1.8;
      case KickOutcome.goal when r.keeperZone == shotZone:
        // Right way, not quite far enough: fingertips short of the ball.
        final dir = (hit.x - startX).sign;
        glove = (hit.x - startX).abs() < 1.0
            ? V3(hit.x, hit.y - 0.55, hit.z)
            : V3(hit.x - dir * 0.5, hit.y - 0.12, hit.z);
        arrive = f.duration + 0.03;
      default:
        glove = ShotAim.zoneCentre(r.keeperZone);
        arrive = f.duration + 0.04;
    }
    _keeper = KeeperMotion(reactAt: react, arriveAt: arrive)..diveTo(glove, startX);
  }

  // ---- finishing -----------------------------------------------------------

  Future<void> _finish() async {
    if (_attempt == null) return;
    setState(() {
      _phase = _Phase.finishing;
      _banner = null;
    });
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
      final res = await widget.repo.complete(_attempt!.id);
      if (!mounted) return;
      final ok = res.fold((_) => null, (r) => r);
      if (ok != null) {
        setState(() {
          _final = ok;
          _phase = _Phase.done;
        });
        if (ok.won) {
          _celebrate = 1.4;
          _sounds.play(PenaltySfx.cheer);
        }
        if (ok.rewardType == 'coins') {
          try {
            context.read<CoinsCubit>().getBalance();
          } catch (_) {}
        }
        return;
      }
    }
    setState(() {
      _phase = _Phase.error;
      _error = 'تعذر حفظ نتيجة المباراة. تحقق من الاتصال ثم أعد المحاولة.';
    });
  }

  Future<bool> _confirmLeave() async {
    if (_phase == _Phase.done || _phase == _Phase.error || _attempt == null) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الخروج من المباراة؟'),
        content: const Text('يمكنك العودة خلال 10 دقائق لإكمال ركلاتك من حيث توقفت.'),
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
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTap: _skip,
                child: CustomPaint(
                  size: box.biggest,
                  painter: PenaltyPainter(
                      scene: _scene, backdrop: _backdrop, keeper: _keeperImage, repaint: _frame),
                ),
              );
            }),
          ),
          if (_backdrop == null)
            const Positioned.fill(
              child: ColoredBox(color: _night, child: Center(child: CircularProgressIndicator(color: _gold))),
            ),
          Positioned(top: 0, left: 0, right: 0, child: SafeArea(bottom: false, child: _hud())),
          if (_banner != null) _bannerWidget(),
          if (_phase == _Phase.replay) _replayBadge(),
          if (_phase == _Phase.aiming && _kickIndex < 2) const _SwipeHint(),
          if (_sendFailed) _connectionLost(),
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
                  child: Text('$_goals / $_need أهداف',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                ),
                if (_attempt?.rewardEligible == true)
                  const Icon(Icons.card_giftcard_rounded, color: _gold, size: 18),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < _kicks.length; i++) _KickDot(state: _kicks[i], current: i == _kickIndex && _phase != _Phase.done),
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
          alignment: const Alignment(0, -0.42),
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
                fontSize: 50,
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

  Widget _replayBadge() => Positioned(
        top: MediaQuery.paddingOf(context).top + 92,
        left: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.fiber_manual_record, color: Color(0xffff3b30), size: 12),
            SizedBox(width: 6),
            Text('إعادة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            SizedBox(width: 10),
            Text('اضغط للتخطي', style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
      );

  Widget _connectionLost() => Positioned.fill(
        child: ColoredBox(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(28),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xff0f1a14), borderRadius: BorderRadius.circular(18)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white70, size: 40),
                const SizedBox(height: 10),
                const Text('انقطع الاتصال أثناء التسديدة',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('سنرسل نفس الركلة مرة أخرى؛ لن تُحتسب مرتين.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
                  onPressed: () {
                    setState(() => _sendFailed = false);
                    _send();
                  },
                  child: const Text('إعادة الإرسال'),
                ),
              ]),
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
                    onPressed: _attempt == null ? _start : _finish,
                    child: const Text('إعادة المحاولة'),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      );

  Widget _resultOverlay() => Positioned.fill(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => ColoredBox(
            color: Colors.black.withValues(alpha: 0.55 * v),
            child: Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 40 * (1 - v)), child: child),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: PenaltyResultPanel(
                result: _final!,
                goalsToWin: _need,
                kicksTaken: _kickIndex,
                onPlayAgain: () => Navigator.of(context).pop(true),
                onExit: () => Navigator.of(context).pop(false),
              ),
            ),
          ),
        ),
      );
}

class _KickDot extends StatelessWidget {
  const _KickDot({required this.state, required this.current});
  final bool? state;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final (Color fill, IconData? icon) = switch (state) {
      true => (const Color(0xff2fbf5b), Icons.check_rounded),
      false => (const Color(0xffe0483e), Icons.close_rounded),
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
      child: icon == null ? null : Icon(icon, size: 16, color: Colors.white),
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

class _SwipeHint extends StatefulWidget {
  const _SwipeHint();
  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

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
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_c.value);
                return Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Transform.translate(offset: Offset(18 * t, -70 * t), child: child),
                );
              },
              child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Text('اسحب من الكرة نحو المرمى',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      );
}
