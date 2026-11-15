import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// Captain Ayoub, cut out for juggling: his standing art split into a body
/// and both legs (thigh + shin each, assets/images/captain, made from the
/// assistant's "default" pose), plus whole-body poses for waving,
/// celebrating and shrugging. All share one scale: 1 m = [pxPerMetre].
///
/// "Right"/"left" here are as the viewer sees him: the right leg is on the
/// right of the screen.
class CaptainArt {
  CaptainArt._(this.body, this.thigh, this.shin, this.thighL, this.shinL, this.wave, this.celebrate, this.shrug);

  final ui.Image body, thigh, shin, thighL, shinL, wave, celebrate, shrug;

  static Future<CaptainArt>? _shared;

  /// One decoded copy for every game that shows him; kept for the app's
  /// lifetime (a few MB), retried if a load fails.
  static Future<CaptainArt> shared() => _shared ??= load().catchError((Object e) {
        _shared = null;
        throw e;
      });

  static Future<CaptainArt> load() async {
    Future<ui.Image> img(String name) async {
      final data = await rootBundle.load('assets/images/captain/$name.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    }

    final all = await Future.wait(
        ['body', 'thigh', 'shin', 'thigh_l', 'shin_l', 'wave', 'celebrate', 'shrug'].map(img));
    return CaptainArt._(all[0], all[1], all[2], all[3], all[4], all[5], all[6], all[7]);
  }

  void dispose() {
    for (final i in [body, thigh, shin, thighL, shinL, wave, celebrate, shrug]) {
      i.dispose();
    }
  }

  // Rig geometry, in asset pixels of the layer canvas (405×1132).
  static const hip = Offset(270, 649);
  static const knee = Offset(311, 802.5);
  static const foot = Offset(337.5, 1009);
  static const hipL = Offset(150, 649);
  static const kneeL = Offset(161, 799);
  static const footL = Offset(105, 1012);
  static const centreX = 202.5;
  static const feetY = 1122.0;
  static const headTop = 6.0;
  static const pxPerMetre = (feetY - headTop) / 1.75;

  /// Where the hip strip kept in [body] ends and each thigh takes over.
  static const thighFadeFrom = 660.0, thighFadeTo = 688.0;
  static const thighFadeFromL = 646.0, thighFadeToL = 672.0;

  /// Bottom-centre anchors of the whole-body poses.
  static const waveAnchor = Offset(243.8, 1150);
  static const celebrateAnchor = Offset(252.8, 1142);
  static const shrugAnchor = Offset(339.8, 1148);

  /// Sideways reach of each juggling foot from his centre, in metres.
  static const legOffset = (337.5 - centreX) / pxPerMetre;
  static const legOffsetLeft = (105 - centreX) / pxPerMetre;
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

  /// Which leg the current [move] uses (feet and knees only).
  bool left = false;
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
    if (y < 0.55) return CaptainMove.foot;
    if (y < 1.0) return CaptainMove.knee;
    if (y < 1.45) return CaptainMove.chest;
    return CaptainMove.head;
  }

  /// Highest a ball can be and still be played (top of the head + a bit).
  static const maxReach = 1.88;

  /// Where his centre should be to meet a ball at [ballX], [ballY] with
  /// the leg on that side.
  static double standFor(double ballX, double ballY, {bool left = false}) {
    final t = ((ballY - 0.95) / 0.45).clamp(0.0, 1.0);
    final leg = left ? CaptainArt.legOffsetLeft : CaptainArt.legOffset;
    final offset = leg * (1 - t * t * (3 - 2 * t));
    return (ballX - offset).clamp(-0.45, 0.45);
  }

  /// The point (metres) he plays a ball at [ballX], [ballY] with, standing
  /// at [standX]: the nearer foot or knee low down, chest or head higher.
  /// Returns null when the ball is above anything he can reach.
  static ({double x, double y, CaptainMove move, bool left})? contact(double standX, double ballX, double ballY) {
    if (ballY > maxReach + 0.05) return null;
    final m = moveFor(ballY);
    final y = switch (m) {
      CaptainMove.foot => ballY.clamp(0.18, 0.55),
      CaptainMove.knee => ballY.clamp(0.55, 1.0),
      CaptainMove.chest => ballY.clamp(1.0, 1.45),
      _ => ballY.clamp(1.45, maxReach),
    };
    if (m == CaptainMove.chest || m == CaptainMove.head) {
      return (x: standX, y: y, move: m, left: false);
    }
    final k = m == CaptainMove.knee ? 0.82 : 1.0;
    final rx = standX + CaptainArt.legOffset * k, lx = standX + CaptainArt.legOffsetLeft * k;
    final useLeft = (ballX - lx).abs() < (ballX - rx).abs();
    return (x: useLeft ? lx : rx, y: y, move: m, left: useLeft);
  }

  void play(CaptainMove m, {bool left = false}) {
    if (m == CaptainMove.whiff && move != CaptainMove.none && _k < 0.5) {
      // Don't cut a real touch short with a swing at air.
      return;
    }
    move = m;
    this.left = left;
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
    // A quick, slightly springy shuffle toward where he's headed.
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

  /// Thigh rotation/foreshortening and shin rotation/foreshortening for a
  /// leg doing [m] at envelope [k]. [dir] is +1 for the right leg, -1 for
  /// the left, so "outward" mirrors.
  static (double, double, double, double) _legPose(CaptainMove m, double k, double dir) {
    switch (m) {
      case CaptainMove.foot:
        return (-0.12 * k * dir, 1 - 0.32 * k, -0.22 * k * dir, 1 - 0.46 * k);
      case CaptainMove.whiff:
        return (-0.08 * k * dir, 1 - 0.22 * k, -0.3 * k * dir, 1 - 0.3 * k);
      case CaptainMove.knee:
        return (-0.05 * k * dir, 1 - 0.74 * k, 0.06 * k * dir, 1 - 0.08 * k);
      case CaptainMove.chest:
      case CaptainMove.head:
        // Tucked legs in the air.
        return (0, 1 - 0.12 * k, 0.1 * k * dir, 1);
      case CaptainMove.none:
        return (0, 1, 0, 1);
    }
  }

  void _paintRig(Canvas canvas, CaptainArt art, Paint paint) {
    final k = _k;
    const pxm = CaptainArt.pxPerMetre;

    // Whole-body motion: a jump for headers, a lean back for the chest,
    // a little bob while shuffling and a slow breath otherwise.
    final moving = (vx.abs() / 1.5).clamp(0.0, 1.0);
    final bob = math.sin(stride).abs() * 0.018 * moving + math.sin(clock * 2.4) * 0.004;
    final lean = switch (move) {
          CaptainMove.chest => -0.14 * k,
          CaptainMove.head => -0.06 * k,
          CaptainMove.knee => (left ? 0.04 : -0.04) * k,
          CaptainMove.foot || CaptainMove.whiff => (left ? 0.02 : -0.02) * k,
          _ => 0.0,
        } +
        (-vx * 0.035).clamp(-0.06, 0.06);
    canvas.translate(0, -(_jump + bob) * pxm);
    canvas.rotate(lean);
    canvas.translate(-CaptainArt.centreX, -CaptainArt.feetY);

    canvas.drawImage(art.body, Offset.zero, paint);

    final both = move == CaptainMove.chest || move == CaptainMove.head;
    final rightPose = (!left || both) ? _legPose(move, k, 1) : _legPose(CaptainMove.none, 0, 1);
    final leftPose = (left || both) ? _legPose(move, k, -1) : _legPose(CaptainMove.none, 0, -1);
    // Legs swing in turn while he shuffles.
    final swing = math.sin(stride) * 0.08 * moving;
    _leg(canvas, paint, art.thigh, art.shin, CaptainArt.hip, CaptainArt.knee, CaptainArt.thighFadeFrom,
        CaptainArt.thighFadeTo, rightPose.$1 + swing, rightPose.$2, rightPose.$3, rightPose.$4);
    _leg(canvas, paint, art.thighL, art.shinL, CaptainArt.hipL, CaptainArt.kneeL, CaptainArt.thighFadeFromL,
        CaptainArt.thighFadeToL, leftPose.$1 - swing, leftPose.$2, leftPose.$3, leftPose.$4);
  }

  /// One leg: the thigh swings/foreshortens about the hip, the shin hangs
  /// from wherever the knee ends up, and the thigh's cut edge fades into
  /// the hip strip the body keeps.
  static void _leg(Canvas canvas, Paint paint, ui.Image thighImg, ui.Image shinImg, Offset hip, Offset knee,
      double fadeFrom, double fadeTo, double thighRot, double thighScale, double shinRot, double shinScale) {
    final kv = knee - hip;
    final ky = Offset(kv.dx, kv.dy * thighScale);
    final c = math.cos(thighRot), sn = math.sin(thighRot);
    final kneeNow = hip + Offset(ky.dx * c - ky.dy * sn, ky.dx * sn + ky.dy * c);

    canvas.save();
    canvas.translate(kneeNow.dx, kneeNow.dy);
    canvas.rotate(thighRot + shinRot);
    canvas.scale(1, shinScale);
    canvas.translate(-knee.dx, -knee.dy);
    canvas.drawImage(shinImg, Offset.zero, paint);
    canvas.restore();

    canvas.save();
    canvas.translate(hip.dx, hip.dy);
    canvas.rotate(thighRot);
    canvas.scale(1, thighScale);
    canvas.translate(-hip.dx, -hip.dy);
    final bounds = Rect.fromLTWH(0, 0, thighImg.width.toDouble(), thighImg.height.toDouble());
    canvas.saveLayer(bounds, Paint());
    canvas.drawImage(thighImg, Offset.zero, paint);
    canvas.drawRect(
        bounds,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = ui.Gradient.linear(
              Offset(0, fadeFrom), Offset(0, fadeTo), const [Color(0x00000000), Color(0xff000000)]));
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
    final leg = left ? CaptainArt.legOffsetLeft : CaptainArt.legOffset;
    final dx = (m == CaptainMove.foot || m == CaptainMove.knee || m == CaptainMove.whiff) ? leg : 0.0;
    return feet.translate(dx * ppm, -h * ppm);
  }
}
