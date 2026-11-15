import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../penalty/penalty_fx.dart';
import 'captain_rig.dart';

/// Keepy-uppy's stage: a lane in the old city at night, seen face-on.
/// The ball's world is the simulator's — x across (0 = centre), y up from
/// the cobbles, metres — and the lane's side walls stand where the
/// simulator bounces the ball (±halfWidth + radius).
class AlleyCamera {
  AlleyCamera(this.size, {double wallX = 0.73})
      : ppm = math.min(size.width / (2 * wallX + 0.34), size.height / 3.45),
        groundY = size.height * 0.885 {
    vp = Offset(size.width / 2, groundY - 1.3 * ppm);
    this.wallX = wallX;
  }

  /// A closer shot of the same lane (the cups table): explicit scale and
  /// where the cobbles meet the bottom of the frame.
  AlleyCamera.closeUp(this.size, {required this.ppm, required this.groundY, double eye = 1.3}) {
    vp = Offset(size.width / 2, groundY - eye * ppm);
    wallX = 0.73;
  }

  final Size size;
  late final double ppm, groundY;
  late final Offset vp;
  late final double wallX;

  /// Half-width of the lane as drawn: wider than the ball's playing strip,
  /// so the walls fall away into the distance instead of boxing him in.
  static const laneHalf = 1.55;

  Offset project(double x, double y) => Offset(size.width / 2 + x * ppm, groundY - y * ppm);

  ({double x, double y}) unproject(Offset p) =>
      (x: (p.dx - size.width / 2) / ppm, y: (groundY - p.dy) / ppm);

  /// A point on the lane's walls/floor [depth] times further away than the
  /// play plane (1 = the play plane, larger = further).
  Offset deep(double x, double y, double depth) {
    final near = project(x, y);
    return vp + (near - vp) / depth;
  }
}

/// Neighbours' windows that light up as the count climbs. Side -1 = left
/// wall; depth along the wall; sill and lintel height in metres.
class _Window {
  const _Window(this.side, this.d1, this.d2, this.y1, this.y2);
  final int side;
  final double d1, d2, y1, y2;
}

const _windowSpots = [
  _Window(-1, 2.05, 2.45, 2.4, 3.1),
  _Window(1, 2.2, 2.6, 2.4, 3.1),
  _Window(-1, 3.4, 4.0, 2.4, 3.1),
  _Window(1, 3.9, 4.6, 2.4, 3.1),
  _Window(-1, 5.6, 6.6, 2.4, 3.1),
  _Window(1, 6.2, 7.3, 2.4, 3.1),
  _Window(-1, 8.6, 10.2, 2.4, 3.1),
  _Window(1, 9.2, 11.0, 2.4, 3.1),
];

const _doorSpots = [
  (-1, 2.65, 3.1),
  (1, 2.9, 3.4),
  (-1, 4.4, 5.1),
  (1, 5.0, 5.7),
];

const _lanternSpots = [(-1, 2.3), (1, 2.6), (-1, 3.7), (1, 4.4), (-1, 6.9), (1, 8.0)];

/// The still parts, painted once per screen size.
class AlleyBackdrop {
  AlleyBackdrop._(this.size, this.image);
  final Size size;
  final ui.Image image;

  void dispose() => image.dispose();

  static const _farDepth = 13.0;

  static Future<AlleyBackdrop> build(Size size, double dpr, {AlleyCamera? camera}) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.scale(dpr);
    paintStill(canvas, camera ?? AlleyCamera(size));
    final pic = rec.endRecording();
    final img = await pic.toImage((size.width * dpr).ceil(), (size.height * dpr).ceil());
    pic.dispose();
    return AlleyBackdrop._(size, img);
  }

  static void paintStill(Canvas canvas, AlleyCamera cam) {
    final size = cam.size;
    const w = AlleyCamera.laneHalf;
    final rng = math.Random(11);

    // Sky: deep night overhead, a warm city glow low down.
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, cam.vp.dy + 40), const [
            Color(0xff070b1f),
            Color(0xff1b1840),
            Color(0xff5a2f4c),
            Color(0xffc9764a),
          ], const [
            0,
            0.45,
            0.8,
            1
          ]));
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 70; i++) {
      final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * cam.vp.dy * 0.8);
      star.color = Colors.white.withValues(alpha: 0.25 + rng.nextDouble() * 0.6);
      canvas.drawCircle(p, 0.5 + rng.nextDouble() * 1.1, star);
    }
    final moon = Offset(size.width * 0.72, cam.vp.dy * 0.28);
    canvas.drawCircle(
        moon,
        cam.ppm * 0.42,
        Paint()
          ..color = const Color(0x33ffe9b0)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, cam.ppm * 0.25));
    canvas.drawCircle(moon, cam.ppm * 0.16, Paint()..color = const Color(0xfffff2cf));
    canvas.drawCircle(moon.translate(cam.ppm * 0.06, -cam.ppm * 0.02), cam.ppm * 0.14,
        Paint()..color = const Color(0xffefe0b6).withValues(alpha: 0.6));

    // The far end of the lane: a gateway with a minaret beyond.
    final fl = cam.deep(-w, 0, _farDepth), fr = cam.deep(w, 0, _farDepth);
    final topY = cam.deep(0, 4.4, _farDepth).dy;
    final minaret = Path()
      ..addRect(Rect.fromLTRB(fr.dx - (fr.dx - fl.dx) * 0.28, topY - cam.ppm * 0.9, fr.dx - (fr.dx - fl.dx) * 0.12, fl.dy));
    canvas.drawPath(minaret, Paint()..color = const Color(0xff2a1f33));
    final mTop = Offset(fr.dx - (fr.dx - fl.dx) * 0.2, topY - cam.ppm * 0.9);
    canvas.drawPath(
        Path()
          ..moveTo(mTop.dx - (fr.dx - fl.dx) * 0.1, mTop.dy)
          ..lineTo(mTop.dx, mTop.dy - cam.ppm * 0.35)
          ..lineTo(mTop.dx + (fr.dx - fl.dx) * 0.1, mTop.dy)
          ..close(),
        Paint()..color = const Color(0xff2a1f33));
    canvas.drawRect(Rect.fromLTRB(fl.dx, topY, fr.dx, fl.dy), Paint()..color = const Color(0xff8f6a52));
    final arch = Path()
      ..moveTo(fl.dx + (fr.dx - fl.dx) * 0.3, fl.dy)
      ..lineTo(fl.dx + (fr.dx - fl.dx) * 0.3, cam.deep(0, 1.9, _farDepth).dy)
      ..arcToPoint(Offset(fr.dx - (fr.dx - fl.dx) * 0.3, cam.deep(0, 1.9, _farDepth).dy),
          radius: Radius.circular((fr.dx - fl.dx) * 0.2))
      ..lineTo(fr.dx - (fr.dx - fl.dx) * 0.3, fl.dy)
      ..close();
    canvas.drawPath(arch, Paint()..color = const Color(0xffffc27a));

    // Floor: cobbles from the gateway to our feet.
    final floor = Path()
      ..moveTo(fl.dx, fl.dy)
      ..lineTo(fr.dx, fr.dy)
      ..lineTo(cam.deep(w, 0, 0.3).dx, cam.deep(w, 0, 0.3).dy)
      ..lineTo(cam.deep(-w, 0, 0.3).dx, cam.deep(-w, 0, 0.3).dy)
      ..close();
    canvas.drawPath(
        floor,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, fl.dy), Offset(0, size.height), const [
            Color(0xff3b2c25),
            Color(0xff6b5444),
            Color(0xff4e3d33),
          ], const [
            0,
            0.6,
            1
          ]));
    canvas.save();
    canvas.clipPath(floor);
    final stone = Paint();
    final gap = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x55120c0a);
    for (var depth = 0.35; depth < _farDepth; depth *= 1.13) {
      final d2 = depth * 1.13;
      final rowShift = (depth * 7).floor().isEven ? 0.5 : 0.0;
      const across = 9;
      for (var i = -1; i <= across; i++) {
        final x1 = -w + (i + rowShift) * 2 * w / across, x2 = x1 + 2 * w / across;
        final a = cam.deep(x1, 0, depth), b = cam.deep(x2, 0, depth);
        final c = cam.deep(x2, 0, d2), d = cam.deep(x1, 0, d2);
        final shade = 0.8 + rng.nextDouble() * 0.35;
        stone.color = Color.fromRGBO((112 * shade).round().clamp(0, 255), (92 * shade).round().clamp(0, 255),
            (76 * shade).round().clamp(0, 255), 1);
        final path = Path()..addPolygon([a, b, c, d], true);
        canvas.drawPath(path, stone);
        gap.strokeWidth = math.max(0.6, (a.dy - d.dy) * 0.12);
        canvas.drawPath(path, gap);
      }
    }
    canvas.restore();
    // Light pooled on the cobbles around the player.
    canvas.drawOval(
        Rect.fromCenter(center: cam.project(0, 0), width: cam.ppm * 2.6, height: cam.ppm * 0.8),
        Paint()
          ..color = const Color(0x40ffcf8a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, cam.ppm * 0.3));

    // Side walls.
    for (final side in const [-1, 1]) {
      final x = w * side;
      final wall = Path()
        ..addPolygon([
          cam.deep(x, 0, 0.3),
          cam.deep(x, 0, _farDepth),
          cam.deep(x, 4.4, _farDepth),
          cam.deep(x, 4.4, 0.3),
        ], true);
      final near = cam.deep(x, 2, 0.6), far = cam.deep(x, 2, _farDepth);
      canvas.drawPath(
          wall,
          Paint()
            ..shader = ui.Gradient.linear(near, far, [
              side < 0 ? const Color(0xffe2d2b4) : const Color(0xffcdbb9a),
              const Color(0xff8a7158),
            ]));
      canvas.save();
      canvas.clipPath(wall);
      // Plaster courses and a darker plinth.
      final course = Paint()
        ..color = const Color(0x22000000)
        ..strokeWidth = 1;
      for (var h = 0.55; h < 4.4; h += 0.55) {
        canvas.drawLine(cam.deep(x, h, 0.3), cam.deep(x, h, _farDepth), course);
      }
      final plinth = Path()
        ..addPolygon([
          cam.deep(x, 0, 0.3),
          cam.deep(x, 0, _farDepth),
          cam.deep(x, 0.45, _farDepth),
          cam.deep(x, 0.45, 0.3),
        ], true);
      canvas.drawPath(plinth, Paint()..color = const Color(0x55392417));
      // Weathering blotches.
      for (var i = 0; i < 18; i++) {
        final d = 0.5 + rng.nextDouble() * 6;
        final p = cam.deep(x, 0.6 + rng.nextDouble() * 3.4, d);
        canvas.drawCircle(
            p,
            cam.ppm * (0.1 + rng.nextDouble() * 0.25) / d,
            Paint()
              ..color = const Color(0x16000000)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, cam.ppm * 0.06 / d));
      }
      canvas.restore();
    }

    // Doors: Tripoli blue, arched, studded.
    for (final (side, d1, d2) in _doorSpots) {
      final x = w * side;
      _wallQuad(canvas, cam, x, d1 - 0.12, d2 + 0.12, 0, 2.45, const Color(0xffefe6d2), arch: true);
      _wallQuad(canvas, cam, x, d1, d2, 0, 2.25, const Color(0xff1e5aa8), arch: true);
      final stud = Paint()..color = const Color(0xffd9b45a);
      for (var r = 0; r < 4; r++) {
        for (var c = 0; c < 3; c++) {
          final dd = 1 / (1 / d1 + (1 / d2 - 1 / d1) * (0.25 + c * 0.25));
          canvas.drawCircle(cam.deep(x, 0.45 + r * 0.38, dd), math.max(0.8, cam.ppm * 0.03 / dd), stud);
        }
      }
    }

    // Windows: dark until a neighbour comes to look (drawn live).
    for (final win in _windowSpots) {
      final x = w * win.side;
      _wallQuad(canvas, cam, x, win.d1 - 0.08, win.d2 + 0.08, win.y1 - 0.12, win.y2 + 0.1,
          const Color(0xffe9dfc9));
      _wallQuad(canvas, cam, x, win.d1, win.d2, win.y1, win.y2, const Color(0xff1d2230));
      // Green shutters folded back.
      _wallQuad(canvas, cam, x, win.d1 - 0.42, win.d1 - 0.1, win.y1, win.y2, const Color(0xff2f7a5a));
      _wallQuad(canvas, cam, x, win.d2 + 0.1, win.d2 + 0.42, win.y1, win.y2, const Color(0xff2f7a5a));
    }

    // Upper storey: small arched windows under the eaves.
    for (final side in const [-1, 1]) {
      final x = w * side;
      for (var d = 3.3 + (side > 0 ? 0.6 : 0); d < 12; d *= 1.32) {
        _wallQuad(canvas, cam, x, d, d * 1.07, 3.75, 4.2, const Color(0xff3a2b2a), arch: true);
      }
    }
    // Sabat: timber beams bridging the lane overhead.
    for (final d in const [2.4, 5.2, 9.0]) {
      final a = cam.deep(-w, 4.15, d), b = cam.deep(w, 4.15, d);
      final a2 = cam.deep(-w, 4.4, d), b2 = cam.deep(w, 4.4, d);
      canvas.drawPath(Path()..addPolygon([a, b, b2, a2], true), Paint()..color = const Color(0xff3b2618));
      final grain = Paint()
        ..color = const Color(0x33000000)
        ..strokeWidth = 1;
      canvas.drawLine(Offset.lerp(a, a2, 0.5)!, Offset.lerp(b, b2, 0.5)!, grain);
    }

    // Lantern brackets (the glow is live).
    for (final (side, d) in _lanternSpots) {
      final x = w * side;
      final at = cam.deep(x, 2.65, d);
      final out = cam.deep(x - side * 0.22, 2.65, d);
      canvas.drawLine(
          at,
          out,
          Paint()
            ..color = const Color(0xff2a2018)
            ..strokeWidth = math.max(1, cam.ppm * 0.03 / d));
    }

    // A painted keepy-uppy target circle on the cobbles.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, cam.ppm * 0.02)
      ..color = const Color(0x55fff3d6);
    canvas.drawOval(
        Rect.fromCenter(center: cam.project(0, 0).translate(0, cam.ppm * 0.02), width: cam.ppm * 1.3, height: cam.ppm * 0.22),
        ring);
  }

  /// A rectangle on a side wall between depths [d1]..[d2] (perspective-
  /// correct) and heights [y1]..[y2]; optionally with an arched top.
  static void _wallQuad(Canvas canvas, AlleyCamera cam, double x, double d1, double d2, double y1, double y2,
      Color color,
      {bool arch = false}) {
    final path = Path();
    final a = cam.deep(x, y1, d1), b = cam.deep(x, y1, d2);
    path.moveTo(a.dx, a.dy);
    path.lineTo(b.dx, b.dy);
    if (arch) {
      final spring = y2 - 0.35;
      path.lineTo(cam.deep(x, spring, d2).dx, cam.deep(x, spring, d2).dy);
      for (var i = 1; i < 12; i++) {
        final t = i / 12;
        final inv = 1 / d2 + (1 / d1 - 1 / d2) * t;
        final h = spring + 0.35 * math.sin(math.pi * t);
        final p = cam.deep(x, h, 1 / inv);
        path.lineTo(p.dx, p.dy);
      }
      path.lineTo(cam.deep(x, spring, d1).dx, cam.deep(x, spring, d1).dy);
    } else {
      path.lineTo(cam.deep(x, y2, d2).dx, cam.deep(x, y2, d2).dy);
      path.lineTo(cam.deep(x, y2, d1).dx, cam.deep(x, y2, d1).dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
}

/// Everything that moves, written by the game loop each frame.
class AlleyScene {
  double clock = 0;
  double ballX = 0, ballY = 0.11, ballR = 0.11;
  double spin = 0;
  bool ballVisible = true;
  final List<Offset> trail = [];
  final captain = CaptainRig();
  final fx = PenaltyFx();

  /// 0..1: how many neighbours have come to their windows.
  double crowd = 0;
  double cheer = 0;
  double flash = 0;
  Offset shake = Offset.zero;

  /// String-light colour pulse on milestones.
  double lightsPulse = 0;
}

class AlleyPainter extends CustomPainter {
  AlleyPainter({required this.scene, required this.backdrop, required this.art, required Listenable repaint})
      : super(repaint: repaint);

  final AlleyScene scene;
  final AlleyBackdrop? backdrop;
  final CaptainArt? art;

  @override
  void paint(Canvas canvas, Size size) {
    final cam = AlleyCamera(size);
    final s = scene;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(s.shake.dx, s.shake.dy);

    final b = backdrop;
    if (b != null && b.size == size) {
      canvas.drawImageRect(b.image, Offset.zero & Size(b.image.width.toDouble(), b.image.height.toDouble()),
          Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
    } else {
      AlleyBackdrop.paintStill(canvas, cam);
    }

    _windows(canvas, cam);
    _lanterns(canvas, cam);
    _stringLights(canvas, cam);

    final a = art;
    if (a != null) s.captain.paint(canvas, a, cam.project(s.captain.x, 0), cam.ppm);
    if (s.ballVisible) _ball(canvas, cam);
    s.fx.paint(canvas, screen: false);
    canvas.restore();

    s.fx.paint(canvas, screen: true);
    // Night grade: darker corners.
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.radial(Offset(size.width / 2, size.height * 0.55), size.longestSide * 0.7,
              const [Color(0x00000000), Color(0x99000000)], const [0.5, 1]));
    if (s.flash > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withValues(alpha: s.flash.clamp(0, 1) * 0.3));
    }
  }

  void _windows(Canvas canvas, AlleyCamera cam) {
    final lit = (scene.crowd * _windowSpots.length).floor();
    for (var i = 0; i < _windowSpots.length; i++) {
      final win = _windowSpots[i];
      final on = i < lit ? 1.0 : (i == lit ? (scene.crowd * _windowSpots.length) % 1 : 0.0);
      if (on <= 0.02) continue;
      final x = AlleyCamera.laneHalf * win.side;
      final path = Path()
        ..addPolygon([
          cam.deep(x, win.y1, win.d1),
          cam.deep(x, win.y1, win.d2),
          cam.deep(x, win.y2, win.d2),
          cam.deep(x, win.y2, win.d1),
        ], true);
      canvas.drawPath(path, Paint()..color = const Color(0xffffc46b).withValues(alpha: on));
      // A neighbour leaning out to watch; jumps when it's going well.
      final dm = (win.d1 + win.d2) / 2;
      final jump = scene.cheer * math.sin(scene.clock * 10 + i * 1.7).abs() * 0.08;
      final head = cam.deep(x - win.side * 0.05, win.y1 + 0.42 + jump, dm);
      final r = cam.ppm * 0.11 / dm;
      final sil = Paint()..color = const Color(0xff2a1a12).withValues(alpha: on);
      canvas.save();
      canvas.clipPath(path);
      canvas.drawCircle(head, r, sil);
      canvas.drawOval(Rect.fromCenter(center: head.translate(0, r * 2.1), width: r * 3.2, height: r * 2.4), sil);
      if (scene.cheer > 0.2) {
        // Arms up.
        final arm = Paint()
          ..color = sil.color
          ..strokeWidth = r * 0.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(head.translate(-r * 1.2, r * 1.4), head.translate(-r * 1.8, -r * 0.8), arm);
        canvas.drawLine(head.translate(r * 1.2, r * 1.4), head.translate(r * 1.8, -r * 0.8), arm);
      }
      canvas.restore();
      // Spill of light on the wall below.
      canvas.drawCircle(
          cam.deep(x, win.y1, dm),
          cam.ppm * 0.5 / dm,
          Paint()
            ..color = const Color(0xffffb35c).withValues(alpha: 0.18 * on)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, cam.ppm * 0.3 / dm));
    }
  }

  void _lanterns(Canvas canvas, AlleyCamera cam) {
    var i = 0;
    for (final (side, d) in _lanternSpots) {
      final x = AlleyCamera.laneHalf * side;
      final p = cam.deep(x - side * 0.22, 2.5, d);
      final flick = 0.85 + 0.15 * math.sin(scene.clock * (7 + i) + i * 2.1);
      final r = cam.ppm * 0.09 / d;
      canvas.drawCircle(
          p,
          r * 7 * flick,
          Paint()
            ..color = const Color(0xffff9f43).withValues(alpha: 0.22 * flick)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 4));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p, width: r * 1.6, height: r * 2.4), Radius.circular(r * 0.4)),
          Paint()..color = const Color(0xffffd38a));
      canvas.drawRect(Rect.fromCenter(center: p.translate(0, -r * 1.4), width: r * 1.9, height: r * 0.5),
          Paint()..color = const Color(0xff2a2018));
      i++;
    }
  }

  void _stringLights(Canvas canvas, AlleyCamera cam) {
    const colors = [Color(0xffffd54a), Color(0xffff6b5f), Color(0xff7fd3ff), Color(0xff8ef0a0)];
    const depths = [1.9, 2.9, 4.4, 6.8];
    for (var r = 0; r < depths.length; r++) {
      final d = depths[r];
      final a = cam.deep(-AlleyCamera.laneHalf, 3.35, d), b = cam.deep(AlleyCamera.laneHalf, 3.35, d);
      final sag = cam.ppm * 0.38 / d;
      Offset at(double t) => Offset.lerp(a, b, t)!.translate(0, sag * 4 * t * (1 - t));
      final wire = Path()..moveTo(a.dx, a.dy);
      for (var i = 1; i <= 20; i++) {
        final p = at(i / 20);
        wire.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
          wire,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(0.6, 1.4 / d)
            ..color = const Color(0xff1a1410));
      const bulbs = 11;
      for (var i = 1; i < bulbs; i++) {
        final p = at(i / bulbs);
        final twinkle = 0.65 + 0.35 * math.sin(scene.clock * 3 + i * 1.3 + r);
        final pulse = scene.lightsPulse * (0.5 + 0.5 * math.sin(scene.clock * 14 + i));
        final col = colors[(i + r) % colors.length];
        final br = math.max(1.4, cam.ppm * 0.028 / d);
        canvas.drawCircle(
            p,
            br * (3 + 2 * pulse),
            Paint()
              ..color = col.withValues(alpha: 0.28 * twinkle + 0.3 * pulse)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, br * 2));
        canvas.drawCircle(p, br, Paint()..color = Color.lerp(col, Colors.white, 0.5)!);
      }
    }
  }

  void _ball(Canvas canvas, AlleyCamera cam) {
    final s = scene;
    final c = cam.project(s.ballX, s.ballY);
    final r = s.ballR * cam.ppm;
    // Shadow on the cobbles: tighter and darker the lower the ball.
    final h = (s.ballY - s.ballR).clamp(0.0, 3.0);
    canvas.drawOval(
        Rect.fromCenter(center: cam.project(s.ballX, 0), width: r * (2.0 + h * 0.6), height: r * (0.45 + h * 0.08)),
        Paint()
          ..color = Colors.black.withValues(alpha: (0.45 - h * 0.12).clamp(0.08, 0.45))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * (0.2 + h * 0.25)));
    for (var i = 0; i < s.trail.length; i++) {
      final a = (i + 1) / (s.trail.length + 1);
      canvas.drawCircle(s.trail[i], r * (0.5 + 0.45 * a), Paint()..color = Colors.white.withValues(alpha: 0.13 * a));
    }
    drawSoccerBall(canvas, c, r, s.spin);
  }

  @override
  bool shouldRepaint(covariant AlleyPainter old) => old.backdrop != backdrop || old.art != art;
}

/// A classic black-and-white ball, panels turning with [spin] (radians).
void drawSoccerBall(Canvas canvas, Offset c, double r, double spin) {
  canvas.drawCircle(c, r, Paint()..color = const Color(0xfff7f7f5));
  canvas.save();
  canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
  final dark = Paint()..color = const Color(0xff17191c);
  // Pentagons on a rotating sphere, projected face-on.
  final ca = math.cos(spin), sa = math.sin(spin);
  for (final n in _ballPanels) {
    final y1 = n[1] * ca - n[2] * sa, z1 = n[1] * sa + n[2] * ca;
    final x1 = n[0];
    if (z1 < -0.2) continue;
    final centre = Offset(c.dx + x1 * r * 0.98, c.dy - y1 * r * 0.98);
    final size = r * 0.36 * (0.55 + 0.45 * z1.clamp(0.0, 1.0));
    final path = Path();
    for (var k = 0; k < 5; k++) {
      final a = spin * 0.5 + k * 2 * math.pi / 5 + x1;
      final p = centre + Offset(math.cos(a) * size, math.sin(a) * size * (0.6 + 0.4 * z1.abs()));
      k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, dark);
  }
  canvas.restore();
  canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(c.translate(-r * 0.35, -r * 0.4), r * 1.45,
            const [Color(0x00ffffff), Color(0x10000000), Color(0x99000000)], const [0, .55, 1]));
  canvas.drawCircle(
      c.translate(-r * 0.32, -r * 0.38),
      r * 0.22,
      Paint()
        ..color = const Color(0x99ffffff)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.15));
}

final List<List<double>> _ballPanels = () {
  final t = (1 + math.sqrt(5)) / 2;
  final raw = [
    [-1, t, 0], [1, t, 0], [-1, -t, 0], [1, -t, 0],
    [0, -1, t], [0, 1, t], [0, -1, -t], [0, 1, -t],
    [t, 0, -1], [t, 0, 1], [-t, 0, -1], [-t, 0, 1],
  ];
  return raw.map((v) {
    final l = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    return [v[0] / l, v[1] / l, v[2] / l];
  }).toList();
}();
