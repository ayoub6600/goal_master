import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui;

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/promotional_credit/data/promotional_credit_repo.dart';

const _goalMasterGreen = Color(0xff3f8d4b);

class FootballChallengeCard extends StatefulWidget {
  const FootballChallengeCard({super.key});

  @override
  State<FootballChallengeCard> createState() => _FootballChallengeCardState();
}

class _FootballChallengeCardState extends State<FootballChallengeCard> {
  late Future<Either<Failure, FootballChallengeStatus>> _status;
  final _repo = getIt<PromotionalCreditRepo>();
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _status = _repo.getFootballChallenge();
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<Either<Failure, FootballChallengeStatus>>(
        future: _status,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result == null || result.isLeft()) return const SizedBox.shrink();
          final status = result.fold((_) => null, (value) => value);
          if (status == null) return const SizedBox.shrink();
          if (!status.enabled) {
            if (!kDebugMode) return const SizedBox.shrink();
            return const Card(
              color: Color(0xffeff7ed),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [
                  Text('⚽', style: TextStyle(fontSize: 34)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تحدي كابتن أيوب',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('اللعبة متوقفة من إعدادات الإدارة'),
                      ],
                    ),
                  ),
                  Icon(Icons.lock_outline, color: _goalMasterGreen),
                ]),
              ),
            );
          }

          final canWin = status.verified &&
              status.rewardAmount > 0 &&
              status.rewardPlaysRemaining > 0;
          final subtitle = !status.verified
              ? 'العب جولات تدريبية، ووثّق هاتفك للمشاركة في الجوائز'
              : canWin
                  ? 'جائزة ${status.rewardAmount.toStringAsFixed(2)} د.ل متاحة اليوم'
                  : 'جولات تدريبية مجانية ومتاحة دائمًا';

          return Card(
            color: const Color(0xffeff7ed),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Text('⚽', style: TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تحدي كابتن أيوب',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _opening ? null : () => _play(context),
                    child: Text(_opening ? 'لحظة...' : 'العب'),
                  ),
                ],
              ),
            ),
          );
        },
      );

  Future<void> _play(BuildContext context) async {
    setState(() => _opening = true);
    final started = await _repo.startFootballChallenge();
    if (!context.mounted) return;
    final attempt = started.fold((_) => null, (value) => value);
    setState(() => _opening = false);
    if (attempt == null || attempt.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('تعذر فتح اللعبة. تحقق من الاتصال ثم حاول مرة أخرى.')),
      );
      setState(() => _status = _repo.getFootballChallenge());
      return;
    }

    await Navigator.of(context).push<void>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _PenaltyChallengePage(attempt: attempt, repo: _repo),
    ));
    if (!mounted) return;
    setState(() => _status = _repo.getFootballChallenge());
  }
}

class _PenaltyChallengePage extends StatefulWidget {
  const _PenaltyChallengePage({required this.attempt, required this.repo});

  final FootballChallengeAttempt attempt;
  final PromotionalCreditRepo repo;

  @override
  State<_PenaltyChallengePage> createState() => _PenaltyChallengePageState();
}

class _PenaltyChallengePageState extends State<_PenaltyChallengePage>
    with TickerProviderStateMixin {
  late FootballChallengeAttempt _attempt;
  late final AnimationController _shotAnimation;
  late final AnimationController _gameLoop;
  Timer? _tellTimer;
  Offset _aim = const Offset(.68, .32);
  FootballChallengeResult? _result;
  bool _sending = false;
  bool _manualAim = false;
  String? _error;
  int _keeperStyle = math.Random().nextInt(4);
  int _strikerStyle = math.Random().nextInt(4);
  bool _tellVisible = false;
  ui.Image? _keeperSprite;
  ui.Image? _strikerSprite;

  @override
  void initState() {
    super.initState();
    _attempt = widget.attempt;
    _shotAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _gameLoop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scheduleKeeperTell();
    _loadSprites();
  }

  Future<void> _loadSprites() async {
    Future<ui.Image> decode(String asset) async {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        targetWidth: 1024,
      );
      try {
        return (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
    }

    try {
      final images = await Future.wait([
        decode('assets/images/football_keeper_strip.webp'),
        decode('assets/images/football_striker_strip.webp'),
      ]);
      if (!mounted) {
        for (final image in images) {
          image.dispose();
        }
        return;
      }
      setState(() {
        _keeperSprite = images[0];
        _strikerSprite = images[1];
      });
    } catch (_) {
      // Keep the game usable with its vector fallback if an asset is unavailable.
    }
  }

  void _scheduleKeeperTell() {
    _tellTimer?.cancel();
    _tellTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _tellVisible = true);
    });
  }

  @override
  void dispose() {
    _tellTimer?.cancel();
    _shotAnimation.dispose();
    _gameLoop.dispose();
    _keeperSprite?.dispose();
    _strikerSprite?.dispose();
    super.dispose();
  }

  void _aimAt(Offset point, Size size) {
    setState(() {
      _manualAim = true;
      _aim = Offset(
        (point.dx / size.width).clamp(.15, .85),
        (point.dy / size.height).clamp(.11, .32),
      );
    });
  }

  Future<void> _shoot() async {
    if (_sending || _result != null) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final meter = _gameLoop.value;
    final shotAim = _manualAim ? _aim : const Offset(.5, .3);
    _gameLoop.stop();
    final response = await widget.repo.submitFootballShot(
      attemptId: _attempt.id,
      aimX: shotAim.dx,
      aimY: shotAim.dy,
      power: meter,
    );
    if (!mounted) return;
    final result = response.fold((_) => null, (value) => value);
    if (result == null) {
      setState(() {
        _sending = false;
        _error = 'تعذر تأكيد نتيجة هذه الجولة. ابدأ جولة جديدة للمتابعة.';
      });
      _gameLoop.repeat(reverse: true);
      return;
    }
    setState(() {
      _aim = shotAim;
      _result = result;
      _sending = false;
    });
    await _shotAnimation.forward(from: 0);
  }

  Future<void> _newRound() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final response = await widget.repo.startFootballChallenge();
    if (!mounted) return;
    final attempt = response.fold((_) => null, (value) => value);
    if (attempt == null || attempt.id.isEmpty) {
      setState(() {
        _sending = false;
        _error = 'تعذر بدء جولة جديدة. حاول مرة أخرى.';
      });
      _gameLoop.repeat(reverse: true);
      return;
    }
    _shotAnimation.reset();
    _tellVisible = false;
    _gameLoop
      ..reset()
      ..repeat(reverse: true);
    setState(() {
      _attempt = attempt;
      _aim = const Offset(.68, .32);
      _manualAim = false;
      _keeperStyle = math.Random().nextInt(4);
      _strikerStyle = math.Random().nextInt(4);
      _result = null;
      _sending = false;
    });
    _scheduleKeeperTell();
  }

  @override
  Widget build(BuildContext context) {
    final rewardRound = _attempt.rewardEligible;
    return Scaffold(
      backgroundColor: const Color(0xfff3f7f1),
      appBar: AppBar(
        title: const Text('ضربة الجزاء'),
        centerTitle: true,
        backgroundColor: const Color(0xfff3f7f1),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            children: [
              _RoundBanner(
                rewardRound: rewardRound,
                rewardAmount: _attempt.rewardAmount,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final size =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _aimAt(details.localPosition, size),
                    onPanUpdate: (details) =>
                        _aimAt(details.localPosition, size),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_shotAnimation, _gameLoop]),
                      builder: (context, _) => CustomPaint(
                        size: size,
                        painter: _StadiumPainter(
                          aim: _manualAim
                              ? _aim
                              : Offset(
                                  .17 + _gameLoop.value * .66,
                                  .12 + (1 - _gameLoop.value) * .19,
                                ),
                          phase: _gameLoop.value,
                          animation: _shotAnimation.value,
                          result: _result,
                          keeperStyle: _keeperStyle,
                          strikerStyle: _strikerStyle,
                          keeperTell: _attempt.keeperTell,
                          tellVisible: _tellVisible,
                          keeperSprite: _keeperSprite,
                          strikerSprite: _strikerSprite,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              if (_result == null)
                AnimatedBuilder(
                  animation: _gameLoop,
                  builder: (context, _) => _TimingMeter(
                    position: _gameLoop.value,
                    manual: _manualAim,
                  ),
                ),
              const SizedBox(height: 8),
              if (_result == null)
                Text(
                  _sending
                      ? 'تجهيز التسديدة...'
                      : !_manualAim
                          ? 'اسحب على أحد أركان المرمى لتحديد الزاوية'
                          : !_tellVisible
                              ? 'راقب حركة الحارس... جهّز اتجاهك'
                              : 'الحارس يميل ${_keeperDirectionLabel(_attempt.keeperTell)}؛ ${_keeperAdvice(_attempt.keeperTell)} وأوقف القوة بدقة',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xff52615a)),
                )
              else
                _ResultBanner(result: _result!, rewardRound: rewardRound),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _sending
                      ? null
                      : _result == null
                          ? _manualAim
                              ? _shoot
                              : null
                          : _newRound,
                  icon: Icon(_result == null
                      ? Icons.sports_soccer
                      : Icons.replay_rounded),
                  label: Text(_sending
                      ? 'لحظة...'
                      : _result == null
                          ? _manualAim
                              ? 'سدد الآن'
                              : 'اختر زاوية التسديد أولاً'
                          : 'العب جولة أخرى'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _goalMasterGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBanner extends StatelessWidget {
  const _RoundBanner({required this.rewardRound, required this.rewardAmount});

  final bool rewardRound;
  final double rewardAmount;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              rewardRound ? const Color(0xffe8f5e9) : const Color(0xffedf1f4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Icon(rewardRound ? Icons.emoji_events : Icons.sports_soccer,
              color: rewardRound ? Colors.amber.shade800 : _goalMasterGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rewardRound
                  ? 'جولة جائزة: ${rewardAmount.toStringAsFixed(2)} د.ل رصيد للحجز'
                  : 'جولة تدريب مجانية — العب براحتك',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      );
}

class _TimingMeter extends StatelessWidget {
  const _TimingMeter({required this.position, required this.manual});

  final double position;
  final bool manual;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xffbd7b16), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'أوقف مؤشر القوة داخل المنطقة الذهبية',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xff31473e),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 13,
                  child: CustomPaint(
                    painter: _TimingMeterPainter(
                      position: position,
                      manual: manual,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class _TimingMeterPainter extends CustomPainter {
  const _TimingMeterPainter({required this.position, required this.manual});

  final double position;
  final bool manual;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(8)),
      Paint()..color = const Color(0xffdbe4dd),
    );
    final sweetSpot =
        Rect.fromLTWH(size.width * .70, 0, size.width * .09, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(sweetSpot, const Radius.circular(8)),
      Paint()..color = const Color(0xff9bca87),
    );
    final x = (size.width * position).clamp(5.0, size.width - 5.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: 5,
            height: size.height + 4),
        const Radius.circular(3),
      ),
      Paint()..color = manual ? _goalMasterGreen : const Color(0xfff4b33f),
    );
  }

  @override
  bool shouldRepaint(covariant _TimingMeterPainter oldDelegate) =>
      oldDelegate.position != position || oldDelegate.manual != manual;
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result, required this.rewardRound});

  final FootballChallengeResult result;
  final bool rewardRound;

  @override
  Widget build(BuildContext context) {
    final rewarded = result.succeeded && result.rewardAmount > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: rewarded ? const Color(0xffe4f4e7) : const Color(0xfff2f4f3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        rewarded
            ? 'هدف! أضيف ${result.rewardAmount.toStringAsFixed(2)} د.ل إلى رصيدك الترويجي.'
            : result.succeeded
                ? 'هدف جميل! هذه جولة تدريبية بلا جائزة.'
                : rewardRound
                    ? 'تصدى لها الحارس! تقدر تكمل اللعب بجولة تدريبية.'
                    : 'تصدى لها الحارس! جرّب زاوية ثانية.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StadiumPainter extends CustomPainter {
  const _StadiumPainter({
    required this.aim,
    required this.phase,
    required this.animation,
    required this.result,
    required this.keeperStyle,
    required this.strikerStyle,
    required this.keeperTell,
    required this.tellVisible,
    required this.keeperSprite,
    required this.strikerSprite,
  });

  final Offset aim;
  final double phase;
  final double animation;
  final FootballChallengeResult? result;
  final int keeperStyle;
  final int strikerStyle;
  final String keeperTell;
  final bool tellVisible;
  final ui.Image? keeperSprite;
  final ui.Image? strikerSprite;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(22)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xff173c50), Color(0xff2f6570), Color(0xff247443)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(bounds),
    );

    for (var band = 0; band < 7; band++) {
      final top = size.height * (.56 + band * .064);
      canvas.drawRect(
        Rect.fromLTWH(0, top, size.width, size.height * .064),
        Paint()
          ..color =
              (band.isEven ? const Color(0xffa4d57f) : const Color(0xff123c32))
                  .withValues(alpha: .09),
      );
    }
    final hud = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .20, size.height * .012, size.width * .60,
          size.height * .045),
      const Radius.circular(14),
    );
    canvas.drawRRect(
        hud, Paint()..color = const Color(0xff091c26).withValues(alpha: .58));
    final keeperNames = ['الصقر', 'الجدار', 'العنكبوت', 'الحارس الذهبي'];
    final hudText = TextPainter(
      text: TextSpan(
        text:
            'تحدي كابتن أيوب  •  ${keeperNames[keeperStyle % keeperNames.length]}',
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width * .56);
    hudText.paint(
        canvas, Offset((size.width - hudText.width) / 2, size.height * .02));

    final light = Paint()
      ..color = const Color(0xffe5f4ff).withValues(alpha: .12);
    for (final side in [0.0, 1.0]) {
      final x = size.width * side;
      final beam = Path()
        ..moveTo(x, size.height * .04)
        ..lineTo(size.width * (side == 0 ? .38 : .62), size.height * .56)
        ..lineTo(size.width * (side == 0 ? .20 : .80), size.height * .56)
        ..close();
      canvas.drawPath(beam, light);
      for (var row = 0; row < 3; row++) {
        canvas.drawCircle(
          Offset(size.width * (side == 0 ? .045 : .955),
              size.height * (.055 + row * .025)),
          size.width * .009,
          Paint()..color = const Color(0xfff8f0c8).withValues(alpha: .8),
        );
      }
    }

    final goal = Rect.fromLTWH(size.width * .10, size.height * .105,
        size.width * .80, size.height * .225);
    final crowd = [
      const Color(0xffef6b58),
      const Color(0xfff0ca65),
      const Color(0xff8db9c8),
      const Color(0xffd9e4d3),
      const Color(0xff778caa),
    ];
    final goalShadow = Paint()
      ..color = const Color(0xff081b24).withValues(alpha: .45);
    canvas.drawRect(goal.inflate(7), goalShadow);
    for (var row = 0; row < 7; row++) {
      for (var seat = 0; seat < 28; seat++) {
        final x = goal.left + goal.width * seat / 28;
        final y = goal.top + goal.height * (.08 + row * .07);
        final color = crowd[(seat * 3 + row * 7 + keeperStyle) % crowd.length];
        canvas.drawCircle(
          Offset(x, y),
          size.width * .0075,
          Paint()..color = color.withValues(alpha: .55),
        );
      }
    }
    final netBackdrop = Paint()
      ..color = const Color(0xffe5f4ff).withValues(alpha: .045);
    canvas.drawRect(goal, netBackdrop);
    final netPaint = Paint()
      ..color = Colors.white.withValues(alpha: .65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRect(goal, netPaint..strokeWidth = 4.5);
    final net = Paint()
      ..color = Colors.white.withValues(alpha: .20)
      ..strokeWidth = 1.1;
    for (var x = 1; x < 12; x++) {
      final dx = goal.left + goal.width * x / 12;
      canvas.drawLine(Offset(dx, goal.top),
          Offset(dx - (dx - size.width / 2) * .035, goal.bottom), net);
    }
    for (var y = 1; y < 7; y++) {
      final dy = goal.top + goal.height * y / 7;
      canvas.drawLine(Offset(goal.left, dy), Offset(goal.right, dy), net);
    }
    canvas.drawLine(
      Offset(goal.left, goal.top),
      Offset(goal.left + goal.width * .025, goal.bottom),
      netPaint..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(goal.right, goal.top),
      Offset(goal.right - goal.width * .025, goal.bottom),
      netPaint..strokeWidth = 3,
    );

    final pitchLine = Paint()
      ..color = Colors.white.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * .84),
          width: size.width * .68,
          height: size.height * .50),
      math.pi,
      math.pi,
      false,
      pitchLine,
    );
    canvas.drawLine(Offset(size.width * .06, size.height * .68),
        Offset(size.width * .94, size.height * .68), pitchLine);
    canvas.drawLine(Offset(size.width * .18, size.height * .68),
        Offset(size.width * .10, size.height * .54), pitchLine);
    canvas.drawLine(Offset(size.width * .82, size.height * .68),
        Offset(size.width * .90, size.height * .54), pitchLine);
    canvas.drawLine(Offset(size.width * .10, size.height * .54),
        Offset(size.width * .90, size.height * .54), pitchLine);
    canvas.drawCircle(Offset(size.width / 2, size.height * .68), 4,
        Paint()..color = Colors.white.withValues(alpha: .75));

    final tellX = keeperTell == 'left'
        ? .22
        : keeperTell == 'right'
            ? .78
            : .50;
    final keeperX = result == null
        ? tellVisible
            ? tellX
            : .36 + (.28 * (.5 + .5 * math.sin(phase * math.pi * 2)))
        : (result!.succeeded
            ? (aim.dx < .5 ? .78 : .22)
            : aim.dx.clamp(.27, .73));
    final keeperDivesLeft = result == null
        ? tellVisible && keeperTell == 'left'
        : result!.succeeded
            ? aim.dx >= .5
            : aim.dx < .5;
    final keeperDivesRight = result == null
        ? tellVisible && keeperTell == 'right'
        : result!.succeeded
            ? aim.dx < .5
            : aim.dx >= .5;
    final keeperFrame = keeperDivesLeft
        ? 1
        : keeperDivesRight
            ? 2
            : 0;
    final keeperSourceWidth =
        keeperSprite == null ? 0.0 : keeperSprite!.width / 3;
    final keeperSourceHeight = keeperSprite?.height.toDouble() ?? 0;
    final keeperSource = keeperSprite == null
        ? Rect.zero
        : Rect.fromLTWH(
            keeperSourceWidth * keeperFrame + keeperSourceWidth * .04,
            keeperSourceHeight * (keeperFrame == 0 ? .02 : .12),
            keeperSourceWidth * (keeperFrame == 0 ? .68 : .92),
            keeperSourceHeight * (keeperFrame == 0 ? .94 : .76),
          );
    final keeperCenter =
        Offset(keeperX * size.width, goal.bottom + size.height * .01);
    _drawSprite(
      canvas,
      keeperSprite,
      keeperSource,
      Rect.fromCenter(
        center: keeperCenter,
        width: size.width * (keeperFrame == 0 ? .20 : .34),
        height: size.height * (keeperFrame == 0 ? .17 : .15),
      ),
    );

    final marker = Offset(aim.dx * size.width, aim.dy * size.height);
    final strikerFrame = result == null ? 0 : 1;
    final strikerFrameWidth =
        strikerSprite == null ? 0.0 : strikerSprite!.width / 2;
    final strikerSource = strikerSprite == null
        ? Rect.zero
        : Rect.fromLTWH(
            strikerFrameWidth * strikerFrame +
                strikerFrameWidth * (strikerFrame == 0 ? .20 : .03),
            strikerSprite!.height * .015,
            strikerFrameWidth * (strikerFrame == 0 ? .60 : .94),
            strikerSprite!.height * .97,
          );
    _drawSprite(
      canvas,
      strikerSprite,
      strikerSource,
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * .81),
        width: size.width * .20,
        height: size.height * .22,
      ),
    );
    if (result == null) {
      final pulse = .55 + math.sin(phase * math.pi * 2) * .35;
      canvas.drawCircle(
          marker,
          13,
          Paint()
            ..color = const Color(0xffffd45c).withValues(alpha: pulse * .32));
      canvas.drawCircle(
          marker,
          7 + pulse * 2,
          Paint()
            ..color = const Color(0xffffd45c)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      _drawBall(canvas, Offset(size.width / 2, size.height * .90), 14);
    } else {
      final start = Offset(size.width / 2, size.height * .90);
      final position =
          Offset.lerp(start, marker, Curves.easeOut.transform(animation))!;
      final trail = Paint()
        ..color =
            const Color(0xfffff1a8).withValues(alpha: .40 * (1 - animation))
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, position, trail);
      _drawBall(canvas, position, 14 - 6 * animation);
    }
  }

  void _drawSprite(
      Canvas canvas, ui.Image? image, Rect source, Rect destination) {
    if (image == null || source.isEmpty || destination.isEmpty) return;
    final fit = applyBoxFit(BoxFit.contain, source.size, destination.size);
    final fittedSource = Alignment.center.inscribe(fit.source, source);
    final fittedDestination =
        Alignment.center.inscribe(fit.destination, destination);
    canvas.drawImageRect(
      image,
      fittedSource,
      fittedDestination,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  void _drawBall(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    final pentagon = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 5;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * .48;
      if (i == 0) {
        pentagon.moveTo(point.dx, point.dy);
      } else {
        pentagon.lineTo(point.dx, point.dy);
      }
    }
    pentagon.close();
    canvas.drawPath(pentagon, Paint()..color = const Color(0xff1d2530));
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: .15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant _StadiumPainter oldDelegate) =>
      oldDelegate.aim != aim ||
      oldDelegate.phase != phase ||
      oldDelegate.animation != animation ||
      oldDelegate.result != result ||
      oldDelegate.keeperStyle != keeperStyle ||
      oldDelegate.strikerStyle != strikerStyle ||
      oldDelegate.keeperTell != keeperTell ||
      oldDelegate.tellVisible != tellVisible ||
      oldDelegate.keeperSprite != keeperSprite ||
      oldDelegate.strikerSprite != strikerSprite;
}

String _keeperDirectionLabel(String tell) => switch (tell) {
      'left' => 'لليسار',
      'right' => 'لليمين',
      _ => 'للوسط',
    };

String _keeperAdvice(String tell) => switch (tell) {
      'left' => 'صوّب يمينًا',
      'right' => 'صوّب يسارًا',
      _ => 'اختر أحد الركنين الجانبيين',
    };
