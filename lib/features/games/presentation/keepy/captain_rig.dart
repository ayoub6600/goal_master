import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Captain Ayoub, cut out for juggling: his standing art split into body,
/// thigh and shin (assets/images/captain, made from the assistant's
/// "default" pose), plus whole-body poses for waving, celebrating and
/// shrugging. All six share one scale: 1 m = [pxPerMetre] asset pixels.
class CaptainArt {
  CaptainArt._(this.body, this.thigh, this.shin, this.wave, this.celebrate, this.shrug);

  final ui.Image body, thigh, shin, wave, celebrate, shrug;

  static Future<CaptainArt> load() async {
    Future<ui.Image> img(String name) async {
      final data = await rootBundle.load('assets/images/captain/$name.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    }

    final all = await Future.wait(
        ['body', 'thigh', 'shin', 'wave', 'celebrate', 'shrug'].map(img));
    return CaptainArt._(all[0], all[1], all[2], all[3], all[4], all[5]);
  }

  void dispose() {
    for (final i in [body, thigh, shin, wave, celebrate, shrug]) {
      i.dispose();
    }
  }

  // Rig geometry, in asset pixels of the body/thigh/shin canvas (405×1132).
  static const hip = Offset(270, 649);
  static const knee = Offset(311, 802.5);
  static const foot = Offset(337.5, 1009);
  static const centreX = 202.5;
  static const feetY = 1122.0;
  static const headTop = 6.0;
  static const pxPerMetre = (feetY - headTop) / 1.75;

  /// Where the hip strip kept in [body] ends and the thigh takes over.
  static const thighFadeFrom = 660.0, thighFadeTo = 688.0;

  /// Bottom-centre anchors of the whole-body poses.
  static const waveAnchor = Offset(243.8, 1150);
  static const celebrateAnchor = Offset(252.8, 1142);
  static const shrugAnchor = Offset(339.8, 1148);

  /// Sideways reach of the juggling leg from his centre, in metres.
  static const legOffset = (337.5 - centreX) / pxPerMetre;
}

enum CaptainMove { none, foot, knee, chest, head, whiff }

enum CaptainPose { rig, wave, celebrate, shrug }

/// The captain's live state: where he stands, what he's doing with the
/// ball, and which pose is showing. Pure animation — the physics never
/// reads any of it.
class CaptainRig {
  double x = 0, vx = 0;
  double targetX = 0;
  CaptainMove move = CaptainMove.none;
  double moveT = 0;
  double stride = 0;
  double clock = 0;

  CaptainPose pose = CaptainPose.wave;
  CaptainPose fromPose = CaptainPose.wave;
  double poseBlend = 1;
  double poseClock = 0;

  static const _moveTime = {
    CaptainMove.foot: 0.30,
    CaptainMove.knee: 0.34,
    CaptainMove.chest: 0.36,
    CaptainMove.head: 0.42,
    CaptainMove.whiff: 0.26,
  };

  /// Body part a ball at height [y] (metres) would be played with.
  static CaptainMove moveFor(double y) {
    if (y < 0.48) return CaptainMove.foot;
    if (y < 0.98) return CaptainMove.knee;
    if (y < 1.42) return CaptainMove.chest;
    return CaptainMove.head;
  }

  /// Where his centre should be to meet a ball at [ballX], [ballY].
  static double standFor(double ballX, double ballY) {
    final t = ((ballY - 0.95) / 0.45).clamp(0.0, 1.0);
    final offset = CaptainArt.legOffset * (1 - t * t * (3 - 2 * t));
    return (ballX - offset).clamp(-0.45, 0.45);
  }

  void play(CaptainMove m) {
    if (m == CaptainMove.whiff && move != CaptainMove.none && _k < 0.5) {
      // Don't cut a real touch short with a swing at air.
      return;
    }
    move = m;
    moveT = 0;
  }

  void setPose(CaptainPose p) {
    if (p == pose) return;
    fromPose = pose;
    pose = p;
    poseBlend = 0;
    poseClock = 0;
  }

  void update(double dt) {
    clock += dt;
    poseClock += dt;
    poseBlend = math.min(1, poseBlend + dt * 5);
    if (move != CaptainMove.none) {
      moveT += dt;
      if (moveT >= _moveTime[move]!) move = CaptainMove.none;
    }
    // A quick, slightly springy shuffle toward where the ball will be.
    const w = 13.0;
    final a = w * w * (targetX - x) - 2 * w * vx;
    vx += a * dt;
    vx = vx.clamp(-3.2, 3.2);
    x += vx * dt;
    stride += vx.abs() * dt * 9;
  }

  /// 0→1→0 envelope of the current move: a snap up, a softer return.
  double get _k {
    if (move == CaptainMove.none) return 0;
    final d = _moveTime[move]!;
    final t = moveT / d;
    const up = 0.24;
    if (t < up) return Curves.easeOutCubic.transform(t / up);
    return 1 - Curves.easeInOutSine.transform((t - up) / (1 - up));
  }

  /// Draws him with his feet centred on [feet] at [ppm] screen pixels per
  /// metre.
  void paint(Canvas canvas, CaptainArt art, Offset feet, double ppm) {
    final s = ppm / CaptainArt.pxPerMetre;

    // Contact shadow.
    final jumpNow = _jump;
    canvas.drawOval(
        Rect.fromCenter(
            center: feet.translate(0, 2),
            width: ppm * (0.62 - jumpNow * 0.6),
            height: ppm * (0.11 - jumpNow * 0.08)),
        Paint()
          ..color = const Color(0x77000000)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, ppm * 0.04));

    if (poseBlend < 1) _paintPose(canvas, art, fromPose, feet, s, 1 - poseBlend);
    _paintPose(canvas, art, pose, feet, s, poseBlend);
  }

  double get _jump {
    if (pose != CaptainPose.rig) return 0;
    final k = _k;
    return switch (move) {
      CaptainMove.head => 0.13 * k,
      CaptainMove.chest => 0.04 * k,
      _ => 0,
    };
  }

  void _paintPose(Canvas canvas, CaptainArt art, CaptainPose p, Offset feet, double s, double alpha) {
    if (alpha <= 0.01) return;
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Color.fromRGBO(0, 0, 0, alpha);
    canvas.save();
    canvas.translate(feet.dx, feet.dy);
    canvas.scale(s);
    switch (p) {
      case CaptainPose.rig:
        _paintRig(canvas, art, paint);
      case CaptainPose.wave:
        final sway = math.sin(poseClock * 2.2) * 0.012;
        canvas.rotate(sway);
        canvas.drawImage(art.wave, -CaptainArt.waveAnchor, paint);
      case CaptainPose.celebrate:
        // Bouncing on his toes.
        final hop = math.sin(poseClock * 9).abs() * 26;
        canvas.translate(0, -hop);
        canvas.drawImage(art.celebrate, -CaptainArt.celebrateAnchor, paint);
      case CaptainPose.shrug:
        canvas.drawImage(art.shrug, -CaptainArt.shrugAnchor, paint);
    }
    canvas.restore();
  }

  void _paintRig(Canvas canvas, CaptainArt art, Paint paint) {
    final k = _k;
    final pxm = CaptainArt.pxPerMetre;

    // Whole-body motion: a jump for headers, a lean back for the chest,
    // a little bob while shuffling and a slow breath otherwise.
    final moving = (vx.abs() / 1.5).clamp(0.0, 1.0);
    final bob = math.sin(stride).abs() * 0.018 * moving + math.sin(clock * 2.4) * 0.004;
    final lean = switch (move) {
          CaptainMove.chest => -0.14 * k,
          CaptainMove.head => -0.06 * k,
          CaptainMove.knee => -0.04 * k,
          _ => 0.0,
        } +
        (-vx * 0.035).clamp(-0.06, 0.06);
    canvas.translate(0, -(_jump + bob) * pxm);
    canvas.rotate(lean);
    canvas.translate(-CaptainArt.centreX, -CaptainArt.feetY);

    // Leg: thigh swings/foreshortens about the hip, the shin hangs from
    // wherever the knee ends up.
    var thighRot = 0.0, thighScale = 1.0, shinRot = 0.0, shinScale = 1.0;
    switch (move) {
      case CaptainMove.foot:
        thighRot = -0.12 * k;
        thighScale = 1 - 0.32 * k;
        shinRot = -0.22 * k;
        shinScale = 1 - 0.46 * k;
      case CaptainMove.whiff:
        thighRot = -0.08 * k;
        thighScale = 1 - 0.22 * k;
        shinRot = -0.3 * k;
        shinScale = 1 - 0.3 * k;
      case CaptainMove.knee:
        thighRot = -0.05 * k;
        thighScale = 1 - 0.74 * k;
        shinRot = 0.06 * k;
        shinScale = 1 - 0.08 * k;
      case CaptainMove.chest:
      case CaptainMove.head:
        // Tucked legs in the air.
        thighScale = 1 - 0.12 * k;
        shinRot = 0.1 * k;
      case CaptainMove.none:
        break;
    }
    // Idle sway of the free leg while running.
    thighRot += math.sin(stride) * 0.08 * moving;

    const hip = CaptainArt.hip, knee = CaptainArt.knee;
    final kv = knee - hip;
    final ky = Offset(kv.dx, kv.dy * thighScale);
    final c = math.cos(thighRot), sn = math.sin(thighRot);
    final kneeNow = hip + Offset(ky.dx * c - ky.dy * sn, ky.dx * sn + ky.dy * c);

    canvas.drawImage(art.body, Offset.zero, paint);

    // Shin first, then the thigh over the knee.
    canvas.save();
    canvas.translate(kneeNow.dx, kneeNow.dy);
    canvas.rotate(thighRot + shinRot);
    canvas.scale(1, shinScale);
    canvas.translate(-knee.dx, -knee.dy);
    canvas.drawImage(art.shin, Offset.zero, paint);
    canvas.restore();

    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(thighRot);
    canvas.scale(1, thighScale);
    canvas.translate(-hip.dx, -hip.dy);
    // Fade the thigh's cut edge into the hip strip the body keeps.
    final bounds = Rect.fromLTWH(0, 0, art.thigh.width.toDouble(), art.thigh.height.toDouble());
    canvas.saveLayer(bounds, Paint());
    canvas.drawImage(art.thigh, Offset.zero, paint);
    canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = ui.Gradient.linear(
              const Offset(0, CaptainArt.thighFadeFrom),
              const Offset(0, CaptainArt.thighFadeTo),
              const [Color(0x00000000), Color(0xff000000)]));
    canvas.restore();
    canvas.restore();
  }

  /// Screen point of the part that meets the ball during [move] — used to
  /// put the dust puff where the boot is.
  Offset contactPoint(Offset feet, double ppm) {
    final m = move == CaptainMove.none ? CaptainMove.foot : move;
    final h = switch (m) {
      CaptainMove.foot || CaptainMove.whiff => 0.38,
      CaptainMove.knee => 0.68,
      CaptainMove.chest => 1.25,
      CaptainMove.head => 1.78,
      CaptainMove.none => 0.38,
    };
    final dx = (m == CaptainMove.foot || m == CaptainMove.knee || m == CaptainMove.whiff) ? CaptainArt.legOffset : 0.0;
    return feet.translate(dx * ppm, -h * ppm);
  }
}
