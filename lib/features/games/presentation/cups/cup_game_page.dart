import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/captain_ayoub_bubble.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/games/data/moving_target_game_repo.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';

import '../keepy/alley_scene.dart';
import '../keepy/captain_rig.dart';
import '../penalty/penalty_fx.dart';
import '../penalty/penalty_reward_card.dart';
import '../penalty/penalty_sounds.dart';

const _gold = Color(0xffffc928);
const _night = Color(0xff07110b);

/// The cups game (تحدي الأكواب): Captain Ayoub's street table in the old
/// lane. The server decides where the ball starts and every swap, and judges
/// the pick; this page only shows it well.
class CupGamePage extends StatefulWidget {
  const CupGamePage({super.key, required this.gameKey, required this.title, this.repo, this.sounds = true});
  final String gameKey, title;
  final MovingTargetGameRepo? repo;
  final bool sounds;

  @override
  State<CupGamePage> createState() => _CupGamePageState();
}

enum _Phase { loading, show, shuffle, pick, reveal, finishing, done, error }

/// Cup and table geometry, metres in the lane's close-up camera.
abstract final class _Table {
  static const top = 0.95;
  static const slots = [-0.42, 0.0, 0.42];
  static const cupH = 0.27, cupTop = 0.15, cupBottom = 0.2;
  static const ball = 0.062;
}

class _CupGamePageState extends State<CupGamePage> with SingleTickerProviderStateMixin {
  late final MovingTargetGameRepo _repo = widget.repo ?? getIt<MovingTargetGameRepo>();
  late final PenaltySounds _sounds = PenaltySounds(enabled: widget.sounds);
  late final Ticker _ticker;
  final _frame = ValueNotifier(0);
  final _fx = PenaltyFx();
  final _captain = CaptainRig();

  AlleyBackdrop? _backdrop;
  Size? _building;
  Size _size = Size.zero;
  CaptainArt? _art;

  _Phase _phase = _Phase.loading;
  String? _error;
  MovingGameAttempt? _attempt;
  MovingGameResult? _result;

  /// identity → slot, and which identity hides the ball.
  final _slotOf = [0, 1, 2];
  int _ballCup = 0;

  // Current swap animation.
  int _swapIndex = -1;
  double _swapT = 0, _swapDur = 0.5;
  (int, int)? _swap; // identities moving: (to the right / front, to the left / back)
  final _from = [0.0, 1.0, 2.0];

  // Lifts: per identity, 0 (down) .. 1 (up).
  final _lift = [0.0, 0.0, 0.0];
  final _liftTarget = [0.0, 0.0, 0.0];

  double _clock = 0, _last = 0, _phaseTime = 0, _deadline = 0;
  int? _picked, _winning;
  bool _hit = false;
  String? _banner;
  Color _bannerColor = Colors.white;
  int _bannerId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => CaptainAyoubBubble.suppressed.value++);
    _captain
      ..setPose(CaptainPose.wave)
      ..poseBlend = 1;
    _ticker = createTicker(_tick)..start();
    _sounds.init();
    CaptainArt.shared().then((a) {
      if (mounted) setState(() => _art = a);
    }).catchError((_) {});
    _start();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.addPostFrameCallback((_) => CaptainAyoubBubble.suppressed.value--);
    _ticker.dispose();
    _sounds.dispose();
    _backdrop?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.loading;
      _error = null;
    });
    final res = await _repo.start(gameKey: widget.gameKey);
    if (!mounted) return;
    final a = res.fold((_) => null, (v) => v);
    if (a == null || a.id.isEmpty) {
      setState(() {
        _phase = _Phase.error;
        _error = 'تعذر بدء التحدي. تحقق من الاتصال أو من إتاحة اللعبة.';
      });
      return;
    }
    _attempt = a;
    _ballCup = a.cupStartIndex.clamp(0, 2);
    for (var i = 0; i < 3; i++) {
      _slotOf[i] = i;
      _from[i] = i.toDouble();
    }
    _deadline = a.remainingMs.clamp(0, a.durationMs) / 1000;
    setState(() => _phase = _Phase.show);
    _phaseTime = 0;
    _showBanner('راقب الكرة!', Colors.white);
  }

  // ---- loop -----------------------------------------------------------------

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = (now - _last).clamp(0.0, 0.05);
    _last = now;
    _clock += dt;
    _phaseTime += dt;
    if (_phase.index >= _Phase.show.index && _phase.index <= _Phase.pick.index) _deadline -= dt;
    _fx.update(dt);
    _captain.update(dt);
    for (var i = 0; i < 3; i++) {
      _lift[i] += (_liftTarget[i] - _lift[i]) * math.min(1, dt * 9);
    }

    switch (_phase) {
      case _Phase.show:
        // Lift the cup with the ball, let it be seen, put it down.
        if (_phaseTime > 0.5 && _phaseTime < 0.6) _liftTarget[_ballCup] = 1;
        if (_phaseTime > 1.7 && _liftTarget[_ballCup] == 1) {
          _liftTarget[_ballCup] = 0;
        }
        if (_phaseTime > 2.15) {
          _sounds.play(PenaltySfx.kick, volume: 0.25);
          _captain.setPose(CaptainPose.rig);
          setState(() {
            _phase = _Phase.shuffle;
            _banner = null;
          });
          _nextSwap();
        }
      case _Phase.shuffle:
        _swapT += dt / _swapDur;
        if (_swapT >= 1) {
          final (a, b) = _swap!;
          _from[a] = _slotOf[a].toDouble();
          _from[b] = _slotOf[b].toDouble();
          _nextSwap();
        }
      case _Phase.pick:
        if (_deadline <= 0) _timeUp();
      case _Phase.reveal:
        break;
      default:
        break;
    }
    _frame.value++;
  }

  void _nextSwap() {
    final swaps = _attempt!.cupSwaps;
    _swapIndex++;
    if (_swapIndex >= swaps.length) {
      _swap = null;
      setState(() => _phase = _Phase.pick);
      _phaseTime = 0;
      _showBanner('وين الكرة؟', _gold);
      HapticFeedback.selectionClick();
      return;
    }
    final s = swaps[_swapIndex];
    final a = _slotOf.indexOf(s[0]), b = _slotOf.indexOf(s[1]);
    if (a < 0 || b < 0) return _nextSwap();
    // Faster as it goes: from a gentle half-second to a blur.
    final k = _swapIndex / math.max(1, swaps.length - 1);
    _swapDur = 0.52 - 0.26 * k;
    _swapT = 0;
    _from[a] = _slotOf[a].toDouble();
    _from[b] = _slotOf[b].toDouble();
    _slotOf[a] = s[1];
    _slotOf[b] = s[0];
    _swap = (a, b);
    _sounds.play(PenaltySfx.whoosh, volume: 0.22);
    HapticFeedback.selectionClick();
  }

  // ---- picking ----------------------------------------------------------------

  ({Offset c, double w, double h}) _cupRect(AlleyCamera cam, int id) {
    final x = _cupX(id);
    final lift = _lift[id] * 0.24;
    final base = cam.project(x, _Table.top + lift);
    final depth = _cupDepth(id);
    final s = 1 + depth * 0.1;
    return (c: base.translate(0, depth * cam.ppm * 0.05), w: _Table.cupBottom * cam.ppm * s, h: _Table.cupH * cam.ppm * s);
  }

  /// Where cup [id] is across the table right now (metres).
  double _cupX(int id) {
    final swap = _swap;
    final moving = swap != null && (swap.$1 == id || swap.$2 == id) && _phase == _Phase.shuffle;
    if (!moving) return _Table.slots[_slotOf[id]];
    final e = Curves.easeInOutCubic.transform(_swapT.clamp(0.0, 1.0));
    final from = _Table.slots[_from[id].round()], to = _Table.slots[_slotOf[id]];
    return from + (to - from) * e;
  }

  /// +1 passing in front (nearer, lower, bigger), -1 behind, 0 resting.
  double _cupDepth(int id) {
    final swap = _swap;
    if (swap == null || _phase != _Phase.shuffle) return 0;
    final arc = math.sin(math.pi * _swapT.clamp(0.0, 1.0));
    if (swap.$1 == id) return arc;
    if (swap.$2 == id) return -arc;
    return 0;
  }

  void _onTap(TapDownDetails d) {
    if (_phase != _Phase.pick || _size == Size.zero) return;
    final cam = _camera(_size);
    for (var id = 0; id < 3; id++) {
      final r = _cupRect(cam, id);
      final rect = Rect.fromLTRB(r.c.dx - r.w * 0.75, r.c.dy - r.h * 1.15, r.c.dx + r.w * 0.75, r.c.dy + r.h * 0.2);
      if (rect.contains(d.localPosition)) {
        _pick(id);
        return;
      }
    }
  }

  Future<void> _pick(int id) async {
    final a = _attempt!;
    setState(() {
      _phase = _Phase.reveal;
      _banner = null;
    });
    _picked = id;
    HapticFeedback.mediumImpact();
    final res = await _repo.shot(attemptId: a.id, eventId: _uuid(), answerIndex: _slotOf[id]);
    if (!mounted) return;
    final shot = res.fold((_) => null, (v) => v);
    if (shot == null) {
      setState(() {
        _phase = _Phase.pick;
        _picked = null;
      });
      _showBanner('تعذر تسجيل اختيارك، حاول مرة أخرى', const Color(0xffff8a65));
      return;
    }
    _hit = shot.hit;
    _winning = shot.answerIndex == null ? null : _slotOf.indexOf(shot.answerIndex!);
    _liftTarget[id] = 1;
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    if (_hit) {
      _sounds.play(PenaltySfx.cheer);
      HapticFeedback.heavyImpact();
      _captain.setPose(CaptainPose.celebrate);
      if (_size != Size.zero) _fx.confetti(_size, count: 120);
      _showBanner('لقيتها!', const Color(0xff6ee7a8));
    } else {
      _sounds.play(PenaltySfx.groan, volume: 0.6);
      _captain.setPose(CaptainPose.shrug);
      _showBanner('مش هنا!', const Color(0xffff8a65));
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      final w = _winning;
      if (w != null && w >= 0) _liftTarget[w] = 1;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (mounted) _finish();
  }

  void _timeUp() {
    setState(() => _phase = _Phase.reveal);
    _showBanner('انتهى الوقت', const Color(0xffff8a65));
    _liftTarget[_ballCup] = 1;
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _finish();
    });
  }

  Future<void> _finish() async {
    final a = _attempt;
    if (a == null) return;
    setState(() {
      _phase = _Phase.finishing;
      _banner = null;
    });
    for (var attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future<void>.delayed(Duration(milliseconds: 700 * attempt));
      final res = await _repo.complete(a.id);
      if (!mounted) return;
      final r = res.fold((_) => null, (v) => v);
      if (r != null) {
        setState(() {
          _result = r;
          _phase = _Phase.done;
        });
        if (r.rewardType == 'coins') {
          try {
            context.read<CoinsCubit>().getBalance();
          } catch (_) {}
        }
        return;
      }
    }
    setState(() {
      _phase = _Phase.error;
      _error = 'تعذر تأكيد النتيجة من الخادم. أعد المحاولة للتحقق من نتيجتك.';
    });
  }

  String _uuid() {
    final random = math.Random.secure();
    String hex(int length) => List.generate(length, (_) => random.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  }

  void _showBanner(String text, Color color) => setState(() {
        _banner = text;
        _bannerColor = color;
        _bannerId++;
      });

  // ---- view -------------------------------------------------------------------

  static AlleyCamera _camera(Size size) {
    final ppm = math.min(size.width / 1.12, size.height / 2.35);
    return AlleyCamera.closeUp(size, ppm: ppm, groundY: size.height * 0.98, eye: 1.45);
  }

  void _ensureBackdrop(Size size) {
    _size = size;
    if (_backdrop?.size == size || _building == size || size.isEmpty) return;
    _building = size;
    AlleyBackdrop.build(size, MediaQuery.devicePixelRatioOf(context), camera: _camera(size)).then((b) {
      if (!mounted || _building != size) return b.dispose();
      setState(() {
        _backdrop?.dispose();
        _backdrop = b;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _night,
      body: Stack(fit: StackFit.expand, children: [
        Positioned.fill(
          child: LayoutBuilder(builder: (context, box) {
            _ensureBackdrop(box.biggest);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _onTap,
              child: CustomPaint(
                size: box.biggest,
                painter: _CupPainter(this, _frame),
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
        Positioned(left: 0, right: 0, bottom: 0, child: SafeArea(top: false, child: _footer())),
        if (_phase == _Phase.error) _errorOverlay(),
        if (_phase == _Phase.done && _result != null) _resultOverlay(),
      ]),
    );
  }

  Widget _hud() {
    final a = _attempt;
    final secs = _deadline.ceil().clamp(0, 999);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(children: [
        _Glass(icon: Icons.close_rounded, onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
                color: const Color(0xcc07110b),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12)),
            child: Row(children: [
              Expanded(
                child: Text(widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
              ),
              if (a?.rewardEligible == true) const Icon(Icons.card_giftcard_rounded, color: _gold, size: 18),
              if (_phase == _Phase.pick) ...[
                const SizedBox(width: 10),
                Icon(Icons.timer_outlined, size: 17, color: secs <= 5 ? const Color(0xffff8a65) : Colors.white70),
                const SizedBox(width: 3),
                Text('$secs',
                    style: TextStyle(
                        color: secs <= 5 ? const Color(0xffff8a65) : Colors.white,
                        fontWeight: FontWeight.w900)),
              ],
            ]),
          ),
        ),
        const SizedBox(width: 10),
        _Glass(
          icon: PenaltySounds.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          onTap: () async {
            await _sounds.setMuted(!PenaltySounds.muted);
            if (mounted) setState(() {});
          },
        ),
      ]),
    );
  }

  Widget _footer() {
    final (IconData icon, String text) = switch (_phase) {
      _Phase.show => (Icons.visibility_rounded, 'الكرة تحت هذا الكوب… ركّز!'),
      _Phase.shuffle => (Icons.sync_rounded, 'تابع الكوب اللي فيه الكرة بعينك'),
      _Phase.pick => (Icons.touch_app_rounded, 'اضغط على الكوب اللي تظن الكرة تحته'),
      _Phase.reveal || _Phase.finishing => (Icons.hourglass_top_rounded, 'لحظة…'),
      _ => (Icons.sports_soccer, ''),
    };
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xcc07110b), borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _gold, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }

  Widget _bannerWidget() => IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -0.62),
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_bannerId),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.scale(scale: 0.4 + 0.6 * v, child: child),
            child: Text(_banner!,
                style: TextStyle(
                  color: _bannerColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 16)],
                )),
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
                      onPressed: () => Navigator.of(context).pop(),
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

  Widget _resultOverlay() {
    final r = _result!;
    final prize = PenaltyResult(
      won: r.won,
      goalsScored: r.hits,
      rewardEligible: r.rewardEligible,
      rewardType: r.rewardType,
      rewardTitle: r.rewardTitle,
      rewardReference: r.rewardReference,
      rewardAmount: r.rewardAmount,
      rewardDetails: r.rewardDetails ?? const {},
    );
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
              result: prize,
              goalsToWin: 1,
              kicksTaken: 1,
              summary: _hit ? 'لقيت الكرة من أول مرة!' : 'الكرة كانت تحت كوب آخر.',
              lostNote: 'ثبّت عينك على الكوب نفسه طول الخلط، ولا تلتفت للأكواب الثانية.',
              onPlayAgain: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => CupGamePage(gameKey: widget.gameKey, title: widget.title, repo: widget.repo, sounds: widget.sounds))),
              onExit: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupPainter extends CustomPainter {
  _CupPainter(this.s, Listenable repaint) : super(repaint: repaint);
  final _CupGamePageState s;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = _CupGamePageState._camera(size);
    final b = s._backdrop;
    if (b != null && b.size == size) {
      canvas.drawImageRect(b.image, Offset.zero & Size(b.image.width.toDouble(), b.image.height.toDouble()),
          Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = _night);
    }

    // Captain behind the table — the table hides him below the waist.
    final art = s._art;
    if (art != null) s._captain.paint(canvas, art, cam.project(0, 0), cam.ppm);

    _table(canvas, cam, size);

    // Ball under its cup (seen only when that cup is up).
    final ballCup = s._ballCup;
    final br = s._cupRect(cam, ballCup);
    final ballSeen = s._lift[ballCup] > 0.02;
    final ballC = cam.project(s._cupX(ballCup), _Table.top + _Table.ball);
    if (ballSeen) {
      canvas.drawOval(Rect.fromCenter(center: ballC.translate(0, _Table.ball * cam.ppm * 0.9), width: br.w * 0.7, height: br.w * 0.14),
          Paint()
            ..color = const Color(0x66000000)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, br.w * 0.05));
      drawSoccerBall(canvas, ballC, _Table.ball * cam.ppm, s._clock * 0.3);
    }

    // Cups: the one passing behind first, the one in front last.
    final order = [0, 1, 2]..sort((a, b) => s._cupDepth(a).compareTo(s._cupDepth(b)));
    for (final id in order) {
      _cup(canvas, cam, id);
    }

    s._fx.paint(canvas, screen: false);
    s._fx.paint(canvas, screen: true);
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.radial(Offset(size.width / 2, size.height * 0.62), size.longestSide * 0.75,
              const [Color(0x00000000), Color(0x99000000)], const [0.55, 1]));
  }

  void _table(Canvas canvas, AlleyCamera cam, Size size) {
    final topY = cam.project(0, _Table.top).dy;
    final w = size.width;
    final back = topY - cam.ppm * 0.16, front = topY + cam.ppm * 0.1;
    // Lamp light pooling on the table.
    canvas.drawCircle(Offset(w / 2, topY), w * 0.6,
        Paint()
          ..color = const Color(0x33ffcf8a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.2));
    // Felt top in perspective.
    final top = Path()
      ..moveTo(w * 0.08, back)
      ..lineTo(w * 0.92, back)
      ..lineTo(w * 1.02, front)
      ..lineTo(-w * 0.02, front)
      ..close();
    canvas.drawPath(
        top,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, back), Offset(0, front), const [Color(0xff175c37), Color(0xff1f7a47)]));
    // Gold trim and the wooden apron with the Goal Master mark.
    canvas.drawRect(Rect.fromLTRB(-2, front, w + 2, front + 6), Paint()..color = const Color(0xffd9b45a));
    final apron = Rect.fromLTRB(-2, front + 6, w + 2, size.height);
    canvas.drawRect(
        apron,
        Paint()
          ..shader = ui.Gradient.linear(apron.topCenter, apron.bottomCenter,
              const [Color(0xff6b3f22), Color(0xff3e2414), Color(0xff2a170c)], const [0, 0.5, 1]));
    final grain = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1.2;
    for (var y = apron.top + 14; y < apron.bottom; y += 13) {
      canvas.drawLine(Offset(0, y), Offset(w, y + math.sin(y) * 2), grain);
    }
    final tp = TextPainter(
      text: const TextSpan(
          text: 'GOAL MASTER',
          style: TextStyle(color: Color(0x66ffd98a), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, apron.top + (cam.ppm * 0.12)));
  }

  void _cup(Canvas canvas, AlleyCamera cam, int id) {
    final r = s._cupRect(cam, id);
    final lifted = s._lift[id];
    final tilt = lifted * -0.22;
    final c = r.c;
    final w = r.w, h = r.h;
    final topW = w * (_Table.cupTop / _Table.cupBottom);

    // Shadow on the felt, softer as the cup rises.
    final shadowC = cam.project(s._cupX(id), _Table.top).translate(0, s._cupDepth(id) * cam.ppm * 0.05 + 2);
    canvas.drawOval(Rect.fromCenter(center: shadowC, width: w * (1.15 + lifted * 0.4), height: w * 0.22),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.42 - lifted * 0.25)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * (0.06 + lifted * 0.1)));

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    // Body: an upturned cup — wide rim on the felt, closed base on top.
    final body = Path()
      ..moveTo(-w / 2, 0)
      ..lineTo(-topW / 2, -h)
      ..quadraticBezierTo(0, -h - w * 0.06, topW / 2, -h)
      ..lineTo(w / 2, 0)
      ..quadraticBezierTo(0, w * 0.12, -w / 2, 0)
      ..close();
    final picked = s._picked == id;
    final glow = s._phase == _Phase.pick ? 0.5 + 0.5 * math.sin(s._clock * 4 + id) : 0.0;
    canvas.drawPath(
        body,
        Paint()
          ..shader = ui.Gradient.linear(Offset(-w / 2, 0), Offset(w / 2, 0), [
            const Color(0xff0f5a2f),
            Color.lerp(const Color(0xff2fbf5b), Colors.white, 0.08 + glow * 0.08)!,
            const Color(0xff1f8a46),
            const Color(0xff0b4424),
          ], const [
            0,
            0.32,
            0.62,
            1
          ]));
    // White stripes like the kit.
    final stripe = Paint()..color = const Color(0xeef4fbf6);
    for (final f in [0.3, 0.62]) {
      final y = -h * f;
      final half = (w / 2) + (topW / 2 - w / 2) * f;
      canvas.drawPath(
          Path()
            ..moveTo(-half, y)
            ..lineTo(half, y)
            ..lineTo(half * 0.985, y - h * 0.07)
            ..lineTo(-half * 0.985, y - h * 0.07)
            ..close(),
          stripe);
    }
    // Gold rim, specular highlight.
    canvas.drawPath(
        Path()
          ..moveTo(-w / 2, 0)
          ..quadraticBezierTo(0, w * 0.12, w / 2, 0),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, w * 0.05)
          ..color = const Color(0xffe2bd5e));
    canvas.drawPath(
        Path()
          ..moveTo(-w * 0.28, -h * 0.08)
          ..lineTo(-topW * 0.3, -h * 0.9),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.07
          ..color = const Color(0x55ffffff)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03));
    if (picked && s._phase != _Phase.done) {
      canvas.drawPath(
          body,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = _gold);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CupPainter old) => true;
}

class _Glass extends StatelessWidget {
  const _Glass({required this.icon, required this.onTap});
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
