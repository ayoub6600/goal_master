import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'penalty_fx.dart';
import 'penalty_world.dart';

const _brandGreen = Color(0xff3f8d4b);

/// Everything that never moves, rasterised once per screen size so each
/// frame only blits it: sky, stands, crowd, floodlights and the pitch.
class PenaltyBackdrop {
  PenaltyBackdrop._(this.size, this.stands, this.crowd, this.pitch);

  final Size size;
  final ui.Image stands, crowd, pitch;

  void dispose() {
    stands.dispose();
    crowd.dispose();
    pitch.dispose();
  }

  static Future<PenaltyBackdrop> build(Size size, double devicePixelRatio) async {
    final dpr = math.min(devicePixelRatio, 2.0);
    final cam = PenaltyCamera(size);
    Future<ui.Image> render(void Function(Canvas) draw) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(dpr);
      draw(canvas);
      final picture = recorder.endRecording();
      return picture
          .toImage((size.width * dpr).ceil(), (size.height * dpr).ceil())
          .whenComplete(picture.dispose);
    }

    final stands = await render((c) => _paintStands(c, cam));
    final crowd = await render((c) => _paintCrowd(c, cam));
    final pitch = await render((c) => _paintPitch(c, cam));
    return PenaltyBackdrop._(size, stands, crowd, pitch);
  }

  // ---- stands ------------------------------------------------------------

  // Two tiers split by a mezzanine; the lower tier sits behind a 2 m wall
  // a dozen metres beyond the goal line, past the advertising boards.
  static const _rows = 46;
  static const _tierBreak = 24;
  static const _standFront = Pitch.goalLineZ + 12.0;
  static double _rowY(int r) => 2.0 + r * 0.46 + (r >= _tierBreak ? 2.2 : 0);
  static double _backZ(int r) => _standFront + r * 0.78 + (r >= _tierBreak ? 1.5 : 0);
  static double _sideX(int r) => 30.0 + r * 0.78;

  static void _paintStands(Canvas canvas, PenaltyCamera cam) {
    final size = cam.size;
    final roofY = cam.project(V3(0, _rowY(_rows) + 1.6, _backZ(_rows))).dy;
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height * .6), const [
            Color(0xff03070e),
            Color(0xff0a1726),
            Color(0xff13263a),
          ], const [0, .55, 1]));

    // Concrete tiers, back stand then the two side stands.
    final tier = Paint();
    for (var r = _rows - 1; r >= 0; r--) {
      final shade = Color.lerp(const Color(0xff1c2733), const Color(0xff0c121a), r / _rows)!;
      tier.color = shade;
      final a = cam.project(V3(-70, _rowY(r + 1), _backZ(r + 1)));
      final b = cam.project(V3(70, _rowY(r), _backZ(r)));
      canvas.drawRect(Rect.fromLTRB(a.dx, a.dy, b.dx, b.dy + 0.6), tier);
      for (final side in const [-1.0, 1.0]) {
        final path = Path()
          ..addPolygon([
            cam.project(V3(side * _sideX(r), _rowY(r), 1.0)),
            cam.project(V3(side * _sideX(r), _rowY(r), _backZ(r))),
            cam.project(V3(side * _sideX(r + 1), _rowY(r + 1), _backZ(r + 1))),
            cam.project(V3(side * _sideX(r + 1), _rowY(r + 1), 1.0)),
          ], true);
        canvas.drawPath(path, tier);
      }
    }

    // The run-off behind the boards and the wall at the foot of the stand.
    canvas.drawPath(
        Path()
          ..addPolygon([
            cam.project(const V3(-80, 0, Pitch.goalLineZ + 4.5)),
            cam.project(const V3(80, 0, Pitch.goalLineZ + 4.5)),
            cam.project(const V3(80, 0, _standFront)),
            cam.project(const V3(-80, 0, _standFront)),
          ], true),
        Paint()..color = const Color(0xff1b4223));
    final wallTop = cam.project(V3(-80, _rowY(0) - 0.1, _standFront));
    final wallBottom = cam.project(const V3(80, 0, _standFront));
    final wall = Rect.fromLTRB(0, wallTop.dy, size.width, wallBottom.dy);
    canvas.drawRect(wall, Paint()..color = const Color(0xff0d1512));
    // Mezzanine fascia between the tiers, with an LED ribbon.
    final midTop = cam.project(V3(0, _rowY(_tierBreak) - 0.2, _backZ(_tierBreak) - 0.6)).dy;
    final midBottom = cam.project(V3(0, _rowY(_tierBreak - 1) + 0.9, _backZ(_tierBreak - 1) + 0.4)).dy;
    canvas.drawRect(Rect.fromLTRB(0, midTop, size.width, midBottom), Paint()..color = const Color(0xff0a0f0d));
    final ribbon = Rect.fromLTRB(0, midTop + (midBottom - midTop) * 0.3, size.width, midTop + (midBottom - midTop) * 0.75);
    canvas.drawRect(
        ribbon,
        Paint()
          ..shader = ui.Gradient.linear(ribbon.centerLeft, ribbon.centerRight, const [
            Color(0xff1f5e2c), Color(0xff3f8d4b), Color(0xff1f5e2c), Color(0xff3f8d4b), Color(0xff1f5e2c),
          ], const [0, .25, .5, .75, 1]));

    // Roof fascia with its floodlight gantry.
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, roofY + 2),
        Paint()..color = const Color(0xff070b11));
    final glow = Paint()
      ..color = const Color(0xffeaf3ff)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final core = Paint()..color = Colors.white;
    for (var i = 0; i < 26; i++) {
      final x = -60 + i * 4.8;
      final p = cam.project(V3(x, _rowY(_rows) + 1.2, _backZ(_rows)));
      final w = cam.scaleAt(_backZ(_rows)) * 1.2;
      canvas.drawRect(Rect.fromCenter(center: p, width: w * 1.6, height: w * 1.1), glow);
      canvas.drawRect(Rect.fromCenter(center: p, width: w, height: w * 0.5), core);
    }
    // Light falling from the gantry onto the pitch.
    canvas.drawRect(
        Offset(0, roofY) & Size(size.width, size.height - roofY),
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, roofY), Offset(0, cam.horizon), const [
            Color(0x2ec8ddff),
            Color(0x00c8ddff),
          ]));
  }

  static const _shirts = [
    _brandGreen, Color(0xff2f6e3a), Color(0xff57a865), Color(0xff3f8d4b),
    Color(0xfff2f4f1), Color(0xffe9ece6), Color(0xff1f3d8a), Color(0xffc83b3b),
    Color(0xfff2c94c), Color(0xff23262b), Color(0xff6b7480), Color(0xff2f6e3a),
  ];
  static const _skins = [
    Color(0xffe0b48c), Color(0xffc68e62), Color(0xff9c6a43), Color(0xff6f4a2e),
    Color(0xfff0caa5),
  ];

  static void _paintCrowd(Canvas canvas, PenaltyCamera cam) {
    final rng = math.Random(11);
    final body = Paint();
    final head = Paint();
    const haze = Color(0xff16222f);

    void person(V3 seat, double depth) {
      final s = cam.scaleAt(seat.z);
      final p = cam.project(seat);
      if (p.dx < -10 || p.dx > cam.size.width + 10 || p.dy < -10) return;
      // Floodlights hit the pitch, not the stands: the crowd sits in
      // half-light and fades into haze further back.
      final fog = (0.22 + depth * 0.55).clamp(0.0, 0.8);
      final lit = 0.42 + rng.nextDouble() * 0.3;
      Color tone(Color c) => Color.lerp(Color.lerp(Colors.black, c, lit)!, haze, fog)!;
      body.color = tone(_shirts[rng.nextInt(_shirts.length)]);
      final w = 0.42 * s, h = 0.5 * s;
      final bob = rng.nextDouble() * 0.08 * s;
      if (w < 1.1) {
        canvas.drawRect(Rect.fromCenter(center: p.translate(0, -bob), width: math.max(w, 0.8), height: math.max(h, 1.0)), body);
        return;
      }
      canvas.drawRRect(
          RRect.fromRectAndCorners(
              Rect.fromLTWH(p.dx - w / 2, p.dy - h - bob, w, h),
              topLeft: Radius.circular(w * 0.35),
              topRight: Radius.circular(w * 0.35)),
          body);
      head.color = tone(_skins[rng.nextInt(_skins.length)]);
      canvas.drawCircle(Offset(p.dx, p.dy - h - bob - 0.1 * s), 0.12 * s, head);
      if (rng.nextDouble() < 0.12) {
        // A raised arm or a scarf held up.
        canvas.drawLine(
            Offset(p.dx + w * 0.4, p.dy - h * 0.8 - bob),
            Offset(p.dx + w * 0.55, p.dy - h * 1.6 - bob),
            Paint()
              ..color = body.color
              ..strokeWidth = math.max(0.8, 0.09 * s));
      }
    }

    for (var r = _rows - 1; r >= 0; r--) {
      final depth = r / _rows;
      for (var x = -70.0; x <= 70; x += 0.56) {
        if (rng.nextDouble() < 0.07) continue; // the odd empty seat
        person(V3(x + rng.nextDouble() * 0.12, _rowY(r) + 0.05, _backZ(r) + 0.25), depth);
      }
      for (final side in const [-1.0, 1.0]) {
        for (var z = _backZ(r); z >= 1.5; z -= 0.56) {
          if (rng.nextDouble() < 0.07) continue;
          person(V3(side * (_sideX(r) + 0.25), _rowY(r) + 0.05, z), depth);
        }
      }
    }
  }

  // ---- pitch ---------------------------------------------------------------

  static void _paintPitch(Canvas canvas, PenaltyCamera cam) {
    final size = cam.size;
    final boardsZ = Pitch.goalLineZ + 4.5;
    final top = cam.project(V3(0, 0, boardsZ)).dy;

    // Mowing stripes across the pitch, 2.75 m apart, plus fainter lanes
    // along it so the grass reads as a cut chequerboard.
    const light = Color(0xff3a8a42), dark = Color(0xff2f7738);
    var z = boardsZ;
    var band = 0;
    while (z > cam.z + 0.2) {
      final next = math.max(cam.z + 0.2, z - 2.75);
      final y0 = cam.project(V3(0, 0, z)).dy;
      final y1 = next <= cam.z + 0.25 ? size.height : cam.project(V3(0, 0, next)).dy;
      canvas.drawRect(Rect.fromLTRB(0, y0, size.width, y1 + 0.5),
          Paint()..color = band.isEven ? light : dark);
      z = next;
      band++;
    }
    final lane = Paint()..color = const Color(0x0f000000);
    for (var x = -40.0; x < 40; x += 10) {
      canvas.drawPath(
          Path()
            ..addPolygon([
              cam.project(V3(x, 0, boardsZ)),
              cam.project(V3(x + 5, 0, boardsZ)),
              cam.project(V3(x + 5, 0, cam.z + 0.6)),
              cam.project(V3(x, 0, cam.z + 0.6)),
            ], true),
          lane);
    }

    // Turf: soft mottling first so the cut doesn't read as flat paint, then
    // short blades whose size follows perspective.
    final rng = math.Random(3);
    final patch = Paint();
    for (var i = 0; i < 900; i++) {
      final wz = cam.z + 0.6 + math.pow(rng.nextDouble(), 1.3) * (boardsZ - cam.z - 0.6);
      final wx = (rng.nextDouble() - 0.5) * 2 * (5 + (wz - cam.z) * 0.85);
      final p = cam.project(V3(wx, 0, wz));
      final s = cam.scaleAt(wz);
      final r = s * (0.25 + rng.nextDouble() * 0.6);
      patch
        ..color = (rng.nextBool() ? const Color(0xff58b35e) : const Color(0xff1d5524))
            .withValues(alpha: 0.05 + rng.nextDouble() * 0.06)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5);
      canvas.drawOval(Rect.fromCenter(center: p, width: r * 2, height: r * 0.7), patch);
    }
    final blade = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 14000; i++) {
      final wz = cam.z + 0.5 + math.pow(rng.nextDouble(), 2.2) * (boardsZ - cam.z - 0.5);
      final wx = (rng.nextDouble() - 0.5) * 2 * (5 + (wz - cam.z) * 0.85);
      final p = cam.project(V3(wx, 0, wz));
      final s = cam.scaleAt(wz);
      final h = 0.018 * s * (0.6 + rng.nextDouble() * 0.8);
      if (h < 0.9) continue;
      final lean = (rng.nextDouble() - 0.5) * h * 0.5;
      blade
        ..strokeWidth = math.max(0.5, 0.0045 * s)
        ..color = Color.lerp(const Color(0xff2a6a30), const Color(0xff63b866), rng.nextDouble())!
            .withValues(alpha: 0.28 + rng.nextDouble() * 0.3);
      canvas.drawPath(
          Path()
            ..moveTo(p.dx, p.dy)
            ..quadraticBezierTo(p.dx + lean * 0.2, p.dy - h * 0.6, p.dx + lean, p.dy - h),
          blade..style = PaintingStyle.stroke);
    }

    // Markings.
    final line = Paint()..color = const Color(0xe6f4f7f2);
    void mark(V3 a, V3 b) {
      const w = 0.06;
      final za = math.max(a.z, cam.z + 0.6), zb = math.max(b.z, cam.z + 0.6);
      if (a.z == b.z) {
        canvas.drawPath(
            Path()
              ..addPolygon([
                cam.project(V3(a.x, 0, za - w)), cam.project(V3(b.x, 0, zb - w)),
                cam.project(V3(b.x, 0, zb + w)), cam.project(V3(a.x, 0, za + w)),
              ], true),
            line);
      } else {
        canvas.drawPath(
            Path()
              ..addPolygon([
                cam.project(V3(a.x - w, 0, za)), cam.project(V3(b.x - w, 0, zb)),
                cam.project(V3(b.x + w, 0, zb)), cam.project(V3(a.x + w, 0, za)),
              ], true),
            line);
      }
    }

    const g = Pitch.goalLineZ;
    mark(const V3(-34, 0, g), const V3(34, 0, g));
    mark(const V3(-9.16, 0, g), const V3(-9.16, 0, g - 5.5));
    mark(const V3(9.16, 0, g), const V3(9.16, 0, g - 5.5));
    mark(const V3(-9.16, 0, g - 5.5), const V3(9.16, 0, g - 5.5));
    mark(const V3(-20.16, 0, g), const V3(-20.16, 0, -5.5));
    mark(const V3(20.16, 0, g), const V3(20.16, 0, -5.5));
    canvas.drawPath(
        Path()
          ..addPolygon([
            for (var a = 0.0; a < math.pi * 2; a += math.pi / 16)
              cam.project(V3(math.cos(a) * 0.08, 0, math.sin(a) * 0.08)),
          ], true),
        Paint()..color = const Color(0x8cf4f7f2));

    // Worn turf around the spot and in the goalmouth.
    for (final c in [const V3(0, 0, 0), const V3(0, 0, g - 0.6)]) {
      final p = cam.project(c);
      final s = cam.scaleAt(c.z);
      canvas.drawOval(
          Rect.fromCenter(center: p, width: 2.4 * s, height: 0.5 * s),
          Paint()
            ..color = const Color(0x305b4a2a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.25 * s));
    }

    // Shadows of the goal frame and net cast by the floodlights.
    final shadow = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(
        Path()
          ..addPolygon([
            cam.project(const V3(-Pitch.halfGoal, 0, g)),
            cam.project(const V3(Pitch.halfGoal, 0, g)),
            cam.project(V3(Pitch.halfGoal + 0.3, 0, g + Pitch.netDepthAt(0))),
            cam.project(V3(-Pitch.halfGoal - 0.3, 0, g + Pitch.netDepthAt(0))),
          ], true),
        shadow);

    // Light pooling on the box, darker towards the camera.
    canvas.drawRect(
        Rect.fromLTRB(0, top, size.width, size.height),
        Paint()
          ..shader = ui.Gradient.radial(cam.project(const V3(0, 0, 7)), size.width * 0.9, const [
            Color(0x18fff7e0),
            Color(0x00000000),
            Color(0x55000000),
          ], const [0, 0.55, 1]));
  }
}

/// Live scene state written by the game loop and read by the painter.
class PenaltyScene {
  double clock = 0;
  V3 ball = Pitch.ballSpot;
  double ballSpin = 0;
  double spinTilt = 0;
  final List<Offset> trail = [];
  KeeperPose keeper = KeeperPose(
      V3(0, KeeperSprite.standingHeight / 2, Pitch.keeperZ), KeeperFrame.ready, 0);
  NetRipple? ripple;
  double netClock = 0;
  double crowdJump = 0;
  double flash = 0;
  Offset shake = Offset.zero;
  double zoom = 1;
  V3 zoomFocus = const V3(0, 1.2, Pitch.goalLineZ);
  double letterbox = 0;
  String? boardMessage;
  List<V3> guide = const [];
  double guideReach = 0;
  ShotAim? reticle;
  int flashSeed = 0;

  /// Hit effects, plus the strike's squash, speed streaks and the red pulse
  /// of a decisive kick. [power] is the live swipe power (-1 when idle).
  final fx = PenaltyFx();
  double squash = 0;
  double speed = 0;
  double tension = 0;
  double power = -1;
}

class PenaltyPainter extends CustomPainter {
  PenaltyPainter({
    required this.scene,
    required this.backdrop,
    required this.keeper,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final PenaltyScene scene;
  final PenaltyBackdrop? backdrop;
  final ui.Image? keeper;

  static final _icosa = _icosahedron();
  static final _boardText = <String, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    final cam = PenaltyCamera(size);
    final s = scene;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(s.shake.dx, s.shake.dy);
    if (s.zoom != 1) {
      final f = cam.project(s.zoomFocus);
      canvas.translate(f.dx, f.dy);
      canvas.scale(s.zoom);
      canvas.translate(-f.dx, -f.dy);
    }

    final b = backdrop;
    if (b != null && b.size == size) {
      final dst = Offset.zero & size;
      final paint = Paint()..filterQuality = FilterQuality.medium;
      canvas.drawImageRect(b.stands, Offset.zero & Size(b.stands.width.toDouble(), b.stands.height.toDouble()), dst, paint);
      canvas.drawImageRect(b.crowd, Offset.zero & Size(b.crowd.width.toDouble(), b.crowd.height.toDouble()),
          dst.translate(0, -s.crowdJump), paint);
      _cameraFlashes(canvas, cam);
      _boards(canvas, cam);
      canvas.drawImageRect(b.pitch, Offset.zero & Size(b.pitch.width.toDouble(), b.pitch.height.toDouble()), dst, paint);
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xff0a1726));
    }

    final ballBehindLine = s.ball.z > Pitch.goalLineZ + 0.12;
    _net(canvas, cam, back: true);
    if (ballBehindLine) _ball(canvas, cam);
    _net(canvas, cam, back: false);
    _frame(canvas, cam);
    _keeper(canvas, cam);
    _guide(canvas, cam);
    _powerRing(canvas, cam);
    if (!ballBehindLine) _ball(canvas, cam);
    s.fx.paint(canvas, screen: false);

    canvas.restore();

    PenaltyFx.speedLines(canvas, size, s.speed, s.clock);
    s.fx.paint(canvas, screen: true);
    PenaltyFx.tension(canvas, size, s.tension, s.clock);

    // Lens and grade, outside the camera transform.
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.radial(Offset(size.width / 2, size.height * 0.45),
              size.longestSide * 0.75, const [Color(0x00000000), Color(0x8c000000)], const [0.55, 1]));
    if (s.flash > 0) {
      canvas.drawRect(Offset.zero & size,
          Paint()..color = Colors.white.withValues(alpha: s.flash.clamp(0, 1) * 0.35));
    }
    if (s.letterbox > 0) {
      final h = size.height * 0.09 * s.letterbox;
      final bar = Paint()..color = Colors.black;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, h), bar);
      canvas.drawRect(Rect.fromLTWH(0, size.height - h, size.width, h), bar);
    }
  }

  void _cameraFlashes(Canvas canvas, PenaltyCamera cam) {
    if (scene.crowdJump <= 0.05) return;
    final rng = math.Random(scene.flashSeed);
    final glow = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    final count = (scene.crowdJump * 10).round();
    for (var i = 0; i < count; i++) {
      final r = rng.nextInt(PenaltyBackdrop._rows);
      final p = cam.project(V3(-55 + rng.nextDouble() * 110,
          PenaltyBackdrop._rowY(r) + 0.8, PenaltyBackdrop._backZ(r)));
      canvas.drawCircle(p, 1.4 + rng.nextDouble() * 1.4, glow);
    }
  }

  void _boards(Canvas canvas, PenaltyCamera cam) {
    const z = Pitch.goalLineZ + 4.5;
    final tl = cam.project(const V3(-60, 0.9, z));
    final br = cam.project(const V3(60, 0, z));
    final rect = Rect.fromLTRB(tl.dx, tl.dy, br.dx, br.dy);
    canvas.drawRect(rect, Paint()..color = const Color(0xff0b1410));
    final panelW = 9.0 * cam.scaleAt(z);
    final goal = scene.boardMessage != null;
    final pulse = goal ? (0.6 + 0.4 * math.sin(scene.clock * 14)) : 1.0;
    var i = 0;
    for (var x = rect.left; x < rect.right; x += panelW, i++) {
      final panel = Rect.fromLTWH(x + 0.5, rect.top + 0.5, panelW - 1, rect.height - 1);
      final bg = goal
          ? Color.lerp(const Color(0xff7a5a00), const Color(0xffffc928), pulse)!
          : (i.isEven ? const Color(0xff1f5e2c) : const Color(0xff0d2114));
      canvas.drawRect(panel, Paint()..color = bg);
      final text = goal ? scene.boardMessage! : (i.isEven ? 'GOAL MASTER' : 'احجز ملعبك الآن');
      final painter = _boardText.putIfAbsent('$text${panel.height.round()}${goal ? 'g' : ''}', () {
        return TextPainter(
          text: TextSpan(
              text: text,
              style: TextStyle(
                  color: goal ? const Color(0xff1b1300) : (i.isEven ? Colors.white : const Color(0xff9be29f)),
                  fontSize: panel.height * 0.58,
                  fontWeight: FontWeight.w900,
                  letterSpacing: panel.height * 0.06)),
          textDirection: RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr,
          maxLines: 1,
        )..layout();
      });
      canvas.save();
      canvas.clipRect(panel);
      painter.paint(canvas, panel.center - Offset(painter.width / 2, painter.height / 2));
      canvas.restore();
    }
    // LED sheen.
    canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter,
              const [Color(0x22ffffff), Color(0x00ffffff), Color(0x33000000)], const [0, .45, 1]));
  }

  // ---- goal ----------------------------------------------------------------

  static const _mesh = 0.14;
  static const _backTopY = Pitch.netTop;

  V3 _netPoint(double x, double y, bool roof, double t) {
    final ripple = scene.ripple;
    if (roof) {
      // y here is 0..1 from the crossbar back to the top of the back net.
      final push = ripple?.push(x, Pitch.goalHeight, t) ?? 0;
      return V3(x, Pitch.goalHeight + (_backTopY - Pitch.goalHeight) * y,
          Pitch.goalLineZ + Pitch.netDepthAt(_backTopY) * y + push * 0.4 * y);
    }
    final push = ripple?.push(x, y, t) ?? 0;
    return V3(x, y, Pitch.goalLineZ + Pitch.netDepthAt(y) + push);
  }

  void _net(Canvas canvas, PenaltyCamera cam, {required bool back}) {
    final t = scene.netClock;
    final mesh = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.5, cam.scaleAt(Pitch.goalLineZ) * 0.012)
      ..color = const Color(0x8cf2f5f8);

    if (back) {
      // Darken behind the mesh so it reads against the crowd.
      final shade = Path()
        ..addPolygon([
          cam.project(const V3(-Pitch.halfGoal, Pitch.goalHeight, Pitch.goalLineZ)),
          cam.project(const V3(Pitch.halfGoal, Pitch.goalHeight, Pitch.goalLineZ)),
          cam.project(V3(Pitch.halfGoal, 0, Pitch.goalLineZ + Pitch.netDepthAt(0))),
          cam.project(V3(-Pitch.halfGoal, 0, Pitch.goalLineZ + Pitch.netDepthAt(0))),
        ], true);
      canvas.drawPath(shade, Paint()..color = const Color(0x55050a08));

      final cols = (Pitch.goalWidth / _mesh).ceil();
      final rows = (_backTopY / _mesh).ceil();
      final path = Path();
      for (var i = 0; i <= cols; i++) {
        final x = -Pitch.halfGoal + i * Pitch.goalWidth / cols;
        for (var j = 0; j <= rows; j++) {
          final p = cam.project(_netPoint(x, j * _backTopY / rows, false, t));
          j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
      }
      for (var j = 0; j <= rows; j++) {
        final y = j * _backTopY / rows;
        for (var i = 0; i <= cols; i++) {
          final p = cam.project(_netPoint(-Pitch.halfGoal + i * Pitch.goalWidth / cols, y, false, t));
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, mesh);

      // Stanchions holding the net up at the back.
      final bar = Paint()
        ..color = const Color(0xffbfc6cc)
        ..strokeWidth = math.max(1, cam.scaleAt(13) * 0.05);
      for (final x in const [-Pitch.halfGoal, Pitch.halfGoal]) {
        canvas.drawLine(cam.project(V3(x, 0, Pitch.goalLineZ + Pitch.netDepthAt(0))),
            cam.project(V3(x, _backTopY, Pitch.goalLineZ + Pitch.netDepthAt(_backTopY))), bar);
      }
      return;
    }

    // Roof and side panels sit in front of anything inside the goal.
    final path = Path();
    final cols = (Pitch.goalWidth / _mesh).ceil();
    const depthRows = 7;
    for (var i = 0; i <= cols; i++) {
      final x = -Pitch.halfGoal + i * Pitch.goalWidth / cols;
      for (var j = 0; j <= depthRows; j++) {
        final p = cam.project(_netPoint(x, j / depthRows, true, t));
        j == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
    }
    for (var j = 0; j <= depthRows; j++) {
      for (var i = 0; i <= cols; i++) {
        final p = cam.project(_netPoint(-Pitch.halfGoal + i * Pitch.goalWidth / cols, j / depthRows, true, t));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
    }
    for (final x in const [-Pitch.halfGoal, Pitch.halfGoal]) {
      for (var y = 0.0; y <= Pitch.goalHeight; y += _mesh) {
        final a = cam.project(V3(x, y, Pitch.goalLineZ));
        final yb = math.min(y, _backTopY);
        final bp = cam.project(V3(x, yb, Pitch.goalLineZ + Pitch.netDepthAt(yb)));
        path
          ..moveTo(a.dx, a.dy)
          ..lineTo(bp.dx, bp.dy);
      }
      for (var d = 0.0; d <= 1.0001; d += 0.125) {
        final top = V3(x, Pitch.goalHeight + (_backTopY - Pitch.goalHeight) * d,
            Pitch.goalLineZ + Pitch.netDepthAt(_backTopY) * d);
        final bottom = V3(x, 0, Pitch.goalLineZ + Pitch.netDepthAt(0) * d);
        final a = cam.project(top), bp = cam.project(bottom);
        path
          ..moveTo(a.dx, a.dy)
          ..lineTo(bp.dx, bp.dy);
      }
    }
    canvas.drawPath(path, mesh..color = const Color(0x66f2f5f8));
  }

  void _frame(Canvas canvas, PenaltyCamera cam) {
    const r = 0.06;
    const g = Pitch.goalLineZ;
    final s = cam.scaleAt(g);
    // Ground contact shadow.
    canvas.drawRect(
        Rect.fromPoints(cam.project(const V3(-Pitch.halfGoal - 0.2, 0.02, g)),
            cam.project(const V3(Pitch.halfGoal + 0.2, -0.02, g))),
        Paint()
          ..color = const Color(0x66000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.05 * s));

    Shader cylinder(Rect rect, bool vertical) => ui.Gradient.linear(
        vertical ? rect.centerLeft : rect.topCenter,
        vertical ? rect.centerRight : rect.bottomCenter,
        const [Color(0xff9aa3ab), Color(0xffffffff), Color(0xfff4f6f8), Color(0xffaeb6bd)],
        const [0, .35, .6, 1]);

    for (final x in const [-Pitch.halfGoal - r, Pitch.halfGoal + r]) {
      final rect = Rect.fromPoints(cam.project(V3(x - r, Pitch.goalHeight + 2 * r, g)),
          cam.project(V3(x + r, 0, g)));
      canvas.drawRect(rect, Paint()..shader = cylinder(rect, true));
    }
    final bar = Rect.fromPoints(
        cam.project(const V3(-Pitch.halfGoal - 2 * r, Pitch.goalHeight + 2 * r, g)),
        cam.project(const V3(Pitch.halfGoal + 2 * r, Pitch.goalHeight, g)));
    canvas.drawRRect(RRect.fromRectAndRadius(bar, Radius.circular(r * s)), Paint()..shader = cylinder(bar, false));
  }

  // ---- keeper --------------------------------------------------------------

  void _keeper(Canvas canvas, PenaltyCamera cam) {
    final pose = scene.keeper;
    final s = cam.scaleAt(pose.centre.z);

    // Shadow: tight under his feet standing, long under him when he's flat.
    final lying = pose.frame != KeeperFrame.ready;
    final airborne = math.max(0.0, pose.centre.y - (lying ? KeeperSprite.lyingHalf : KeeperSprite.standingHeight / 2));
    final shadowAt = cam.project(V3(pose.centre.x, 0, pose.centre.z + 0.15));
    final spread = (lying ? 2.2 : 0.9) * (1 - math.min(0.4, airborne * 0.25));
    canvas.drawOval(
        Rect.fromCenter(center: shadowAt, width: spread * s, height: 0.28 * s),
        Paint()
          ..color = Colors.black.withValues(alpha: (0.45 - airborne * 0.22).clamp(0.12, 0.45))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, (0.08 + airborne * 0.08) * s));

    final image = keeper;
    if (image == null) return;
    final ghost = pose.ghost;
    if (ghost != null && pose.ghostAlpha > 0.01) _keeperSprite(canvas, cam, image, ghost, pose.ghostAlpha);
    _keeperSprite(canvas, cam, image, pose, pose.alpha);
  }

  void _keeperSprite(Canvas canvas, PenaltyCamera cam, ui.Image image, KeeperPose pose, double alpha) {
    if (alpha <= 0.01) return;
    final s = cam.scaleAt(pose.centre.z);
    final src = switch (pose.frame) {
      KeeperFrame.ready => KeeperSprite.ready,
      KeeperFrame.diveLeft => KeeperSprite.diveLeft,
      KeeperFrame.diveRight => KeeperSprite.diveRight,
    };
    final scale = s / KeeperSprite.pxPerMetre;
    final centre = cam.project(pose.centre);
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-pose.rotation);
    if (pose.sx != 1 || pose.sy != 1) {
      // Squash from the feet when standing, from the middle when flying.
      final pivotY = pose.frame == KeeperFrame.ready ? src.height * scale / 2 : 0.0;
      canvas.translate(0, pivotY);
      canvas.scale(pose.sx, pose.sy);
      canvas.translate(0, -pivotY);
    }
    final dst = Rect.fromCenter(center: Offset.zero, width: src.width * scale, height: src.height * scale);
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Color.fromRGBO(0, 0, 0, alpha.clamp(0.0, 1.0));
    // The first two frames overlap on the strip between x=468 and x=488: the
    // ready frame's right glove sits below y=300 there, the dive's leading
    // glove above it. Draw each frame around the other's fingers.
    final parts = switch (pose.frame) {
      KeeperFrame.ready => const [Rect.fromLTRB(28, 92, 468, 660), Rect.fromLTRB(468, 300, 488, 660)],
      KeeperFrame.diveLeft => const [Rect.fromLTRB(468, 180, 1300, 300), Rect.fromLTRB(490, 300, 1300, 532)],
      KeeperFrame.diveRight => [src],
    };
    for (final part in parts) {
      canvas.drawImageRect(
          image,
          part,
          Rect.fromLTWH(dst.left + (part.left - src.left) * scale, dst.top + (part.top - src.top) * scale,
              part.width * scale, part.height * scale),
          paint);
    }
    canvas.restore();
  }

  // ---- ball ----------------------------------------------------------------

  void _ball(Canvas canvas, PenaltyCamera cam) {
    final ball = scene.ball;
    final s = cam.scaleAt(ball.z);
    final r = Pitch.ballRadius * s;
    final c = cam.project(ball);

    final h = ball.y - Pitch.ballRadius;
    final shadow = cam.project(V3(ball.x + h * 0.15, 0, ball.z + h * 0.25));
    canvas.drawOval(
        Rect.fromCenter(center: shadow, width: r * (2.3 + h * 0.5), height: r * (0.55 + h * 0.1)),
        Paint()
          ..color = Colors.black.withValues(alpha: (0.5 - h * 0.12).clamp(0.08, 0.5))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * (0.25 + h * 0.3)));

    final trail = scene.trail;
    if (trail.isNotEmpty) {
      // A comet tail: soft glow underneath, a bright tapering core on top.
      final glow = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2, r * 0.45));
      final core = Paint();
      for (var i = 0; i < trail.length; i++) {
        final a = (i + 1) / (trail.length + 1);
        glow.color = const Color(0xffffe9a8).withValues(alpha: 0.16 * a);
        canvas.drawCircle(trail[i], r * (0.35 + 0.75 * a), glow);
      }
      for (var i = 1; i < trail.length; i++) {
        final a = i / trail.length;
        core
          ..color = Colors.white.withValues(alpha: 0.38 * a)
          ..strokeWidth = r * (0.15 + 1.1 * a)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(trail[i - 1], trail[i], core);
      }
      core
        ..color = Colors.white.withValues(alpha: 0.38)
        ..strokeWidth = r * 1.2;
      canvas.drawLine(trail.last, c, core);
    }

    canvas.save();
    if (scene.squash > 0.01) {
      // Boot-on-leather squash, springing back.
      final q = scene.squash;
      canvas.translate(c.dx, c.dy);
      canvas.scale(1 + 0.28 * q, 1 - 0.24 * q);
      canvas.translate(-c.dx, -c.dy);
    }
    canvas.drawCircle(c, r, Paint()..color = const Color(0xfff7f7f5));

    // Classic 32-panel ball: draw the 12 pentagons that face the camera.
    final spin = scene.ballSpin, tilt = scene.spinTilt;
    final ca = math.cos(spin), sa = math.sin(spin), ct = math.cos(tilt), st = math.sin(tilt);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    final dark = Paint()..color = const Color(0xff17191c);
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.4, r * 0.04)
      ..color = const Color(0x55000000);
    List<double> rot(List<double> v) {
      // Spin about the x axis (topspin), then tilt about z for side spin.
      final y1 = v[1] * ca - v[2] * sa, z1 = v[1] * sa + v[2] * ca;
      return [v[0] * ct - y1 * st, v[0] * st + y1 * ct, z1];
    }

    for (final n in _icosa) {
      final rn = rot(n);
      if (rn[2] > 0.25) continue; // facing away from the camera
      final verts = <Offset>[];
      final helper = (rn[0].abs() < 0.9) ? [1.0, 0.0, 0.0] : [0.0, 1.0, 0.0];
      final u = _norm(_cross(rn, helper));
      final w = _cross(rn, u);
      const ang = 0.37;
      for (var k = 0; k < 5; k++) {
        final a = k * 2 * math.pi / 5;
        final dir = [
          rn[0] * math.cos(ang) + (u[0] * math.cos(a) + w[0] * math.sin(a)) * math.sin(ang),
          rn[1] * math.cos(ang) + (u[1] * math.cos(a) + w[1] * math.sin(a)) * math.sin(ang),
        ];
        verts.add(Offset(c.dx + dir[0] * r, c.dy - dir[1] * r));
      }
      final path = Path()..addPolygon(verts, true);
      canvas.drawPath(path, dark);
      for (final v in verts) {
        final out = Offset(v.dx + (v.dx - c.dx) * 0.35, v.dy + (v.dy - c.dy) * 0.35);
        canvas.drawLine(v, out, seam);
      }
    }
    canvas.restore();

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(c.translate(-r * 0.35, -r * 0.4), r * 1.45, const [
            Color(0x00ffffff),
            Color(0x10000000),
            Color(0x8c000000),
          ], const [0, .55, 1]));
    canvas.drawCircle(
        c.translate(-r * 0.32, -r * 0.38),
        r * 0.22,
        Paint()
          ..color = const Color(0x99ffffff)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.15));
    canvas.restore();

    if (ball.z < 0.05 && ball.y <= Pitch.ballRadius + 0.01) {
      // Sitting in the turf on the spot: a few blades in front of it.
      final blade = Paint()
        ..strokeWidth = math.max(0.8, r * 0.05)
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xff2f7738);
      final rng = math.Random(5);
      for (var i = 0; i < 14; i++) {
        final x = c.dx + (rng.nextDouble() - 0.5) * r * 2.2;
        final y = c.dy + r * (0.75 + rng.nextDouble() * 0.25);
        canvas.drawLine(Offset(x, y), Offset(x + (rng.nextDouble() - 0.5) * r * 0.2, y - r * (0.15 + rng.nextDouble() * 0.25)), blade);
      }
    }
  }

  /// Live power while the finger is still on the glass: an arc that fills
  /// green to gold to red around the ball.
  void _powerRing(Canvas canvas, PenaltyCamera cam) {
    final p = scene.power;
    if (p < 0) return;
    final c = cam.project(scene.ball);
    final r = Pitch.ballRadius * cam.scaleAt(scene.ball.z) * 1.9;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
        rect,
        math.pi * 0.75,
        math.pi * 1.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = const Color(0x55000000));
    final col = Color.lerp(
        Color.lerp(const Color(0xff2fbf5b), const Color(0xffffd54a), (p * 2).clamp(0.0, 1.0)),
        const Color(0xffff5a4f),
        ((p - 0.5) * 2).clamp(0.0, 1.0))!;
    canvas.drawArc(
        rect,
        math.pi * 0.75,
        math.pi * 1.5 * p.clamp(0.02, 1.0),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = col);
  }

  void _guide(Canvas canvas, PenaltyCamera cam) {
    final pts = scene.guide;
    if (pts.length < 2 || scene.guideReach <= 0) return;
    final n = (pts.length * scene.guideReach).floor().clamp(1, pts.length);
    for (var i = 0; i < n; i++) {
      final p = cam.project(pts[i]);
      final fade = 1 - i / pts.length;
      canvas.drawCircle(p, 2.2 + 3.5 * fade,
          Paint()..color = Colors.white.withValues(alpha: 0.25 + 0.55 * fade));
    }
    final aim = scene.reticle;
    if (aim != null && scene.guideReach >= 1) {
      final p = cam.project(aim.world);
      final good = !aim.offTarget && !aim.onWoodwork;
      final col = good ? const Color(0xffffd54a) : const Color(0xffff5a4f);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = col;
      canvas.drawCircle(p, 11, ring);
      canvas.drawCircle(p, 3, Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(covariant PenaltyPainter old) =>
      old.backdrop != backdrop || old.keeper != keeper;

  static List<List<double>> _icosahedron() {
    final t = (1 + math.sqrt(5)) / 2;
    final raw = [
      [-1, t, 0], [1, t, 0], [-1, -t, 0], [1, -t, 0],
      [0, -1, t], [0, 1, t], [0, -1, -t], [0, 1, -t],
      [t, 0, -1], [t, 0, 1], [-t, 0, -1], [-t, 0, 1],
    ];
    return raw.map((v) => _norm(v.map((e) => e.toDouble()).toList())).toList();
  }

  static List<double> _cross(List<double> a, List<double> b) => [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
      ];

  static List<double> _norm(List<double> v) {
    final l = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    return [v[0] / l, v[1] / l, v[2] / l];
  }
}
