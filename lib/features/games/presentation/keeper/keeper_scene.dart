import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../keepy/alley_scene.dart' show drawSoccerBall;
import '../keepy/captain_rig.dart';
import '../penalty/penalty_fx.dart';
import 'keeper_model.dart';

/// The keeper's-eye view. Two mappings share the screen:
///
/// - the goal mouth fills it — posts at the side edges, the bar near the
///   top, the line at the bottom — so wherever the ball crosses the line is
///   simply where it is on screen (goal metres ↔ screen, [goal]/[toGoal]);
/// - the pitch beyond is a perspective view from the keeper's eyes
///   ([world]), where Captain Ayoub stands on the spot.
class KeeperView {
  KeeperView(this.size)
      : kx = (size.width / 2 - size.width * 0.04) / KeeperModel.halfWidth,
        barY = size.height * 0.2,
        lineY = size.height * 0.915,
        focal = size.width * 2.8,
        horizonY = size.height * 0.47 {
    ky = (lineY - barY) / KeeperModel.bar;
  }

  final Size size;
  final double kx, barY, lineY, focal, horizonY;
  late final double ky;

  static const eyeY = 1.45;

  /// Camera-to-spot distance (m), and the ball's resting point there.
  static const spotZ = 12.0;

  Offset goal(double x, double y) => Offset(size.width / 2 + x * kx, lineY - y * ky);

  ({double x, double y}) toGoal(Offset p) => (x: (p.dx - size.width / 2) / kx, y: (lineY - p.dy) / ky);

  /// A point on the pitch [z] metres in front of the keeper's eyes.
  Offset world(double x, double y, double z) =>
      Offset(size.width / 2 + x * focal / z, horizonY + (eyeY - y) * focal / z);

  double scaleAt(double z) => focal / z;

  /// Ball at fraction [u] of its flight to ([tx],[ty]) on the line, bending
  /// by [curl] metres at mid-flight; returns centre and radius. Perspective-
  /// like: it starts small and slow and rushes at you at the end.
  ({Offset c, double r}) ballInFlight(double u, double tx, double ty, double curl) {
    u = u.clamp(0.0, 1.25);
    const z0 = spotZ - 0.4, z1 = 1.0;
    final z = z0 + (z1 - z0) * u;
    final g = (1 / z - 1 / z0) / (1 / z1 - 1 / z0);
    final s0 = world(0, 0.11, z0);
    final s1 = goal(tx, ty);
    final bend = Offset(curl * kx * math.sin(math.pi * u.clamp(0.0, 1.0)), 0);
    final r0 = 0.11 * scaleAt(z0);
    final r1 = size.width * 0.068;
    return (c: s0 + (s1 - s0) * g + bend, r: r0 + (r1 - r0) * g);
  }
}

class KeeperBackdrop {
  KeeperBackdrop._(this.size, this.image);
  final Size size;
  final ui.Image image;
  void dispose() => image.dispose();

  static Future<KeeperBackdrop> build(Size size, double dpr) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.scale(dpr);
    paintStill(canvas, KeeperView(size));
    final pic = rec.endRecording();
    final img = await pic.toImage((size.width * dpr).ceil(), (size.height * dpr).ceil());
    pic.dispose();
    return KeeperBackdrop._(size, img);
  }

  static void paintStill(Canvas canvas, KeeperView v) {
    final size = v.size;
    final w = size.width;
    final rng = math.Random(4);

    // Night sky and the stadium bowl.
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, v.horizonY),
              const [Color(0xff050913), Color(0xff0c1a2b), Color(0xff13263a)], const [0, 0.5, 1]));
    final boardsTop = v.world(0, 1.0, 45).dy;
    final standTop = size.height * 0.035;
    for (var row = 0; row < 34; row++) {
      final t = row / 33;
      final y = boardsTop - 6 - (boardsTop - 6 - standTop) * t;
      final r = 2.1 + 2.4 * t;
      final rowShade = 0.28 + 0.34 * (1 - t * 0.7);
      canvas.drawRect(Rect.fromLTWH(0, y - r * 1.6, w, r * 2.6),
          Paint()..color = Color.lerp(const Color(0xff0a1422), const Color(0xff1a2c40), 1 - t)!);
      for (var x = -r; x < w + r; x += r * 2.15) {
        final shirt = [
          const Color(0xff2fbf5b),
          const Color(0xffe9eef2),
          const Color(0xff2a7a3c),
          const Color(0xffd94b45),
          const Color(0xff3466b8),
          const Color(0xffefc14a),
        ][rng.nextInt(6)];
        final jx = x + (rng.nextDouble() - 0.5) * r * 0.6;
        final muted = Color.lerp(shirt, const Color(0xff7d8a96), 0.35)!;
        canvas.drawCircle(Offset(jx, y + r * 0.55), r * 0.95, Paint()..color = Color.lerp(Colors.black, muted, rowShade)!);
        canvas.drawCircle(Offset(jx, y - r * 0.55), r * 0.55,
            Paint()..color = Color.lerp(Colors.black, const Color(0xffc8946b), rowShade * 0.9)!);
      }
    }
    // Haze over the stands, so the pitch and the striker carry the eye.
    canvas.drawRect(
        Rect.fromLTRB(0, 0, w, boardsTop),
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, boardsTop),
              const [Color(0x88050913), Color(0x33050913), Color(0x00050913)], const [0, 0.6, 1]));
    // Floodlights on the roof.
    for (final fx in [0.12, 0.38, 0.62, 0.88]) {
      final c = Offset(w * fx, standTop * 0.8);
      canvas.drawCircle(c, w * 0.07, Paint()
        ..color = const Color(0x44fff6d8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w * 0.08, height: w * 0.022), const Radius.circular(3)),
          Paint()..color = const Color(0xfffffbea));
    }
    // Advertising boards along the far end.
    final boards = Rect.fromLTRB(0, boardsTop, w, v.world(0, 0, 45).dy);
    canvas.drawRect(boards, Paint()..color = const Color(0xff0f3b22));
    final tp = TextPainter(
      text: TextSpan(
          text: 'GOAL MASTER  •  GOAL MASTER  •  GOAL MASTER',
          style: TextStyle(color: const Color(0xffbff5cf), fontSize: boards.height * 0.62, fontWeight: FontWeight.w900, letterSpacing: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, boards.center.dy - tp.height / 2));

    // The pitch: mown stripes in perspective, then the box markings.
    final grassTop = boards.bottom;
    canvas.drawRect(Rect.fromLTRB(0, grassTop, w, size.height), Paint()..color = const Color(0xff2f8a3e));
    for (var z = 45.0; z > 1.2; z -= 3.5) {
      final y1 = v.world(0, 0, z).dy, y2 = v.world(0, 0, math.max(1.2, z - 1.75)).dy;
      canvas.drawRect(Rect.fromLTRB(0, y1, w, y2), Paint()..color = const Color(0xff37984a));
    }
    canvas.drawRect(
        Rect.fromLTRB(0, grassTop, w, size.height),
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, grassTop), Offset(0, size.height),
              const [Color(0x55000000), Color(0x00000000), Color(0x22000000)], const [0, 0.35, 1]));
    final line = Paint()
      ..color = const Color(0xd8ffffff)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    void ground(List<(double, double)> pts, double z0) {
      final path = Path();
      for (var i = 0; i < pts.length; i++) {
        final p = v.world(pts[i].$1, 0, pts[i].$2);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      line.strokeWidth = math.max(1.2, v.scaleAt(z0) * 0.09);
      canvas.drawPath(path, line);
    }

    // Camera stands just behind the goal line (z = 1 is the line).
    ground([(-20.16, 17.5), (20.16, 17.5)], 17.5); // penalty area front
    ground([(-9.16, 6.5), (9.16, 6.5)], 6.5); // six-yard box front
    ground([(-9.16, 6.5), (-9.16, 1.2)], 4);
    ground([(9.16, 6.5), (9.16, 1.2)], 4);
    ground([(-20.16, 17.5), (-20.16, 1.2)], 8);
    ground([(20.16, 17.5), (20.16, 1.2)], 8);
    // The D.
    final d = <(double, double)>[];
    for (var a = -0.93; a <= 0.93; a += 0.06) {
      d.add((9.15 * math.sin(a), 1 + 11 + 9.15 * math.cos(a)));
    }
    ground(d, 20);
    // Penalty spot.
    final spot = v.world(0, 0, KeeperView.spotZ);
    canvas.drawOval(Rect.fromCenter(center: spot, width: v.scaleAt(KeeperView.spotZ) * 0.3, height: v.scaleAt(KeeperView.spotZ) * 0.08),
        Paint()..color = Colors.white);

    // Vignette, then the frame we're standing in.
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.radial(Offset(w / 2, size.height * 0.5), size.longestSide * 0.72,
              const [Color(0x00000000), Color(0x88000000)], const [0.55, 1]));
    _frame(canvas, v);
  }

  static void _frame(Canvas canvas, KeeperView v) {
    final w = v.size.width;
    final post = w * 0.045;
    final l = v.goal(-KeeperModel.halfWidth, 0).dx, r = v.goal(KeeperModel.halfWidth, 0).dx;
    final top = v.barY;
    // Goal line under our feet.
    canvas.drawRect(Rect.fromLTRB(0, v.lineY - 3, w, v.lineY + post * 0.5), Paint()..color = const Color(0xeeffffff));
    final paint = Paint()
      ..shader = ui.Gradient.linear(Offset(l - post, 0), Offset(l, 0), const [Color(0xffbfc6cc), Color(0xffffffff)]);
    canvas.drawRect(Rect.fromLTRB(l - post, top - post, l, v.size.height), paint);
    paint.shader = ui.Gradient.linear(Offset(r, 0), Offset(r + post, 0), const [Color(0xffffffff), Color(0xffbfc6cc)]);
    canvas.drawRect(Rect.fromLTRB(r, top - post, r + post, v.size.height), paint);
    paint.shader = ui.Gradient.linear(Offset(0, top - post), Offset(0, top), const [Color(0xffc9d0d6), Color(0xffffffff)]);
    canvas.drawRect(Rect.fromLTRB(l - post, top - post, r + post, top), paint);
    // A hint of net above and beside us.
    final net = Paint()
      ..color = const Color(0x30ffffff)
      ..strokeWidth = 1;
    for (var x = l - post; x > -10; x -= 9) {
      canvas.drawLine(Offset(x, top - post), Offset(x - 30, 0), net);
    }
    for (var x = r + post; x < w + 10; x += 9) {
      canvas.drawLine(Offset(x, top - post), Offset(x + 30, 0), net);
    }
  }
}

/// Live state, written by the game loop.
class KeeperScene {
  double clock = 0;

  // Captain on the spot.
  final captain = CaptainRig();
  double captainZ = KeeperView.spotZ + 1.6;

  // The ball: on the spot, in flight, or bouncing off after the moment.
  bool ballVisible = true;
  Offset? ballAt;
  double ballR = 0;
  double spin = 0;
  final trail = <Offset>[];

  // Gloves: goal-metre centre, how far through a dive (0..1) and its lean.
  double gloveX = KeeperModel.startX, gloveY = KeeperModel.startY;
  double dive = 0, lean = 0;

  Offset? tapMark;
  double tapAge = 0;

  final fx = PenaltyFx();
  double flash = 0;
  Color flashColor = Colors.white;
  Offset shake = Offset.zero;
  double roll = 0;
}

class KeeperPainter extends CustomPainter {
  KeeperPainter({required this.scene, required this.backdrop, required this.art, required this.glove, required Listenable repaint})
      : super(repaint: repaint);

  final KeeperScene scene;
  final KeeperBackdrop? backdrop;
  final CaptainArt? art;
  final ui.Image? glove;

  @override
  void paint(Canvas canvas, Size size) {
    final v = KeeperView(size);
    final s = scene;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(s.shake.dx, s.shake.dy);
    if (s.roll != 0) {
      canvas.translate(size.width / 2, size.height * 0.8);
      canvas.rotate(s.roll);
      // A touch of zoom so the tilted frame never shows its corners.
      final z = 1 + s.roll.abs() * 2.2;
      canvas.scale(z, z);
      canvas.translate(-size.width / 2, -size.height * 0.8);
    }
    final b = backdrop;
    if (b != null && b.size == size) {
      canvas.drawImageRect(b.image, Offset.zero & Size(b.image.width.toDouble(), b.image.height.toDouble()),
          Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
    } else {
      KeeperBackdrop.paintStill(canvas, v);
    }

    final a = art;
    if (a != null) {
      s.captain.paint(canvas, a, v.world(s.captain.x, 0, s.captainZ), v.scaleAt(s.captainZ));
    }

    // Ball (the trail first, so it streams behind).
    for (var i = 0; i < s.trail.length; i++) {
      final k = (i + 1) / (s.trail.length + 1);
      canvas.drawCircle(s.trail[i], s.ballR * (0.3 + 0.55 * k), Paint()..color = Colors.white.withValues(alpha: 0.16 * k));
    }
    final ball = s.ballAt;
    if (s.ballVisible && ball != null) {
      canvas.drawCircle(
          ball.translate(s.ballR * 0.15, s.ballR * 0.25),
          s.ballR * 1.05,
          Paint()
            ..color = const Color(0x55000000)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.ballR * 0.4));
      drawSoccerBall(canvas, ball, s.ballR, s.spin);
    }
    s.fx.paint(canvas, screen: false);

    _gloves(canvas, v);
    _tapMark(canvas);
    canvas.restore();

    s.fx.paint(canvas, screen: true);
    if (s.flash > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = s.flashColor.withValues(alpha: s.flash.clamp(0, 1) * 0.35));
    }
  }

  void _gloves(Canvas canvas, KeeperView v) {
    final g = glove;
    final s = scene;
    // At rest the gloves wait low, out of the striker's way; they rise
    // into place as the dive starts.
    final centre = v.goal(s.gloveX, s.gloveY).translate(0, v.size.height * 0.13 * (1 - s.dive));
    final h = v.size.width * 0.19;
    final spread = v.size.width * (0.15 - 0.06 * s.dive);
    final breathe = math.sin(s.clock * 2.6) * 2.5 * (1 - s.dive);
    for (final side in const [-1.0, 1.0]) {
      final at = centre.translate(side * spread, breathe + h * 0.15);
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(s.lean + side * (0.22 - 0.12 * s.dive));
      final scale = 1 + 0.18 * s.dive;
      canvas.scale(side * scale, scale);
      if (g != null) {
        // The sprite hangs fingers-down; turn it to fingers-up, back of the
        // hand to us.
        canvas.rotate(math.pi * 0.92);
        final dst = Rect.fromCenter(center: Offset.zero, width: h * g.width / g.height, height: h);
        canvas.drawImageRect(g, Offset.zero & Size(g.width.toDouble(), g.height.toDouble()), dst,
            Paint()..filterQuality = FilterQuality.medium);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: h * 0.7, height: h), Radius.circular(h * 0.3)),
            Paint()..color = const Color(0xffe9eef2));
      }
      canvas.restore();
    }
  }

  void _tapMark(Canvas canvas) {
    final p = scene.tapMark;
    if (p == null) return;
    final t = (scene.tapAge / 0.5).clamp(0.0, 1.0);
    canvas.drawCircle(
        p,
        10 + 26 * Curves.easeOut.transform(t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - t) + 0.5
          ..color = const Color(0xffffd54a).withValues(alpha: 1 - t));
  }

  @override
  bool shouldRepaint(covariant KeeperPainter old) => old.backdrop != backdrop || old.art != art || old.glove != glove;
}

Future<ui.Image> loadGlove() async {
  final data = await rootBundle.load('assets/images/keeper/glove.webp');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  return (await codec.getNextFrame()).image;
}
