import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum FxKind { chunk, dust, spark, confetti, ring, star }

/// One short-lived particle. [screen] particles ignore the camera (confetti
/// falling over the whole view); the rest live in the camera's frame.
class FxParticle {
  FxParticle({
    required this.kind,
    required this.p,
    required this.v,
    required this.life,
    required this.size,
    required this.color,
    this.gravity = 0,
    this.drag = 0,
    this.rot = 0,
    this.spin = 0,
    this.screen = false,
  }) : maxLife = life;

  final FxKind kind;
  Offset p, v;
  double life;
  final double maxLife, size, gravity, drag, spin;
  double rot;
  final Color color;
  final bool screen;

  double get t => 1 - (life / maxLife).clamp(0.0, 1.0);
}

/// Hit effects for the shoot-out: turf kicked up by the strike, the
/// shockwave off the boot, sparks off gloves and woodwork, confetti for a goal.
class PenaltyFx {
  final particles = <FxParticle>[];
  final _rng = math.Random();

  static const _turf = [Color(0xff2f7a37), Color(0xff3d8f44), Color(0xff5a4632), Color(0xff26652e)];
  static const _confetti = [
    Color(0xff2fbf5b),
    Color(0xffffffff),
    Color(0xffffd54a),
    Color(0xff7fd3ff),
    Color(0xffff6b5f),
  ];

  bool get isEmpty => particles.isEmpty;

  void update(double dt) {
    for (final q in particles) {
      q.life -= dt;
      q.v = Offset(q.v.dx, q.v.dy + q.gravity * dt) * math.max(0, 1 - q.drag * dt);
      q.p += q.v * dt;
      q.rot += q.spin * dt;
    }
    particles.removeWhere((q) => q.life <= 0);
  }

  double _r(double a, double b) => a + (b - a) * _rng.nextDouble();

  /// The strike: clods and blades of turf, a puff of dust, a shockwave.
  void strike(Offset at, double ballR, {double power = 0.5}) {
    final k = 0.8 + power * 0.7;
    for (var i = 0; i < 26; i++) {
      final a = _r(-math.pi * 0.95, -math.pi * 0.05);
      final speed = _r(120, 520) * k;
      particles.add(FxParticle(
        kind: FxKind.chunk,
        p: at + Offset(_r(-ballR, ballR), ballR * 0.8),
        v: Offset(math.cos(a) * speed * 0.9, math.sin(a) * speed),
        life: _r(0.45, 0.9),
        size: _r(3.0, 6.5) * (ballR / 22).clamp(0.7, 2.0),
        color: _turf[_rng.nextInt(_turf.length)],
        gravity: 1400,
        drag: 0.6,
        rot: _r(0, math.pi),
        spin: _r(-14, 14),
      ));
    }
    for (var i = 0; i < 9; i++) {
      final a = _r(-math.pi, 0);
      particles.add(FxParticle(
        kind: FxKind.dust,
        p: at + Offset(_r(-ballR, ballR) * 0.6, ballR * 0.7),
        v: Offset(math.cos(a) * _r(30, 110), math.sin(a) * _r(15, 60)),
        life: _r(0.5, 0.9),
        size: ballR * _r(0.7, 1.3),
        color: const Color(0xffd8d2b8),
        drag: 2.5,
      ));
    }
    ring(at, ballR, const Color(0xffffffff), grow: 5.5 * k);
    for (var i = 0; i < 8; i++) {
      final a = _r(0, math.pi * 2);
      particles.add(FxParticle(
        kind: FxKind.star,
        p: at,
        v: Offset(math.cos(a), math.sin(a)) * _r(260, 520) * k,
        life: _r(0.14, 0.24),
        size: ballR * _r(0.35, 0.6),
        color: const Color(0xffffffff),
        drag: 6,
        rot: a,
      ));
    }
  }

  void ring(Offset at, double r0, Color color, {double grow = 4, double life = 0.35}) {
    particles.add(FxParticle(
      kind: FxKind.ring,
      p: at,
      v: Offset.zero,
      life: life,
      size: r0,
      color: color,
      spin: grow,
    ));
  }

  /// Glove, post or net contact.
  void sparks(Offset at, double scale, Color color, {int count = 18}) {
    for (var i = 0; i < count; i++) {
      final a = _r(0, math.pi * 2);
      final speed = _r(140, 460) * scale;
      particles.add(FxParticle(
        kind: FxKind.spark,
        p: at,
        v: Offset(math.cos(a) * speed, math.sin(a) * speed),
        life: _r(0.25, 0.55),
        size: _r(1.4, 2.8) * scale,
        color: color,
        gravity: 600,
        drag: 2.2,
      ));
    }
    ring(at, 8 * scale, color, grow: 6, life: 0.3);
  }

  /// A goal: paper raining over the whole screen.
  void confetti(Size size, {int count = 110}) {
    for (var i = 0; i < count; i++) {
      particles.add(FxParticle(
        kind: FxKind.confetti,
        screen: true,
        p: Offset(_r(-20, size.width + 20), _r(-size.height * 0.35, -10)),
        v: Offset(_r(-60, 60), _r(140, 320)),
        life: _r(2.2, 3.6),
        size: _r(5, 10),
        color: _confetti[_rng.nextInt(_confetti.length)],
        gravity: 90,
        drag: 0.4,
        rot: _r(0, math.pi),
        spin: _r(-9, 9),
      ));
    }
  }

  void paint(Canvas canvas, {required bool screen}) {
    final paint = Paint();
    for (final q in particles) {
      if (q.screen != screen) continue;
      final fade = (q.life / q.maxLife).clamp(0.0, 1.0);
      switch (q.kind) {
        case FxKind.chunk:
          paint
            ..color = q.color.withValues(alpha: math.min(1, fade * 2.5))
            ..maskFilter = null
            ..style = PaintingStyle.fill;
          canvas.save();
          canvas.translate(q.p.dx, q.p.dy);
          canvas.rotate(q.rot);
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: q.size * 1.1, height: q.size * 2.2), paint);
          canvas.restore();
        case FxKind.dust:
          paint
            ..color = q.color.withValues(alpha: 0.32 * fade)
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, q.size * 0.45);
          canvas.drawCircle(q.p, q.size * (0.6 + q.t * 1.6), paint);
        case FxKind.spark:
          paint
            ..color = q.color.withValues(alpha: fade)
            ..strokeWidth = q.size
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke
            ..maskFilter = null;
          canvas.drawLine(q.p, q.p - q.v * 0.03, paint);
        case FxKind.star:
          paint
            ..color = q.color.withValues(alpha: 0.85 * fade)
            ..strokeWidth = q.size * 0.35
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke
            ..maskFilter = null;
          final dir = Offset(math.cos(q.rot), math.sin(q.rot));
          canvas.drawLine(q.p, q.p - dir * q.size * 3, paint);
        case FxKind.ring:
          final r = q.size * (1 + q.spin * Curves.easeOutCubic.transform(q.t));
          paint
            ..color = q.color.withValues(alpha: 0.7 * fade)
            ..strokeWidth = math.max(1, q.size * 0.35 * fade)
            ..style = PaintingStyle.stroke
            ..maskFilter = null;
          canvas.drawCircle(q.p, r, paint);
        case FxKind.confetti:
          paint
            ..color = q.color.withValues(alpha: math.min(1, fade * 3))
            ..style = PaintingStyle.fill
            ..maskFilter = null;
          canvas.save();
          canvas.translate(q.p.dx + math.sin(q.rot * 0.7) * 6, q.p.dy);
          canvas.rotate(q.rot);
          // Flipping paper: width breathes as it tumbles.
          canvas.drawRect(
              Rect.fromCenter(center: Offset.zero, width: q.size * (0.25 + 0.75 * math.cos(q.rot * 1.3).abs()), height: q.size * 0.55),
              paint);
          canvas.restore();
      }
    }
  }

  /// Streaks rushing past the edges while the ball is struck hard.
  static void speedLines(Canvas canvas, Size size, double amount, double clock) {
    if (amount <= 0.02) return;
    final rng = math.Random((clock * 30).floor());
    final c = Offset(size.width / 2, size.height * 0.42);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..shader = null;
    for (var i = 0; i < 26; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final r0 = size.longestSide * (0.38 + rng.nextDouble() * 0.12);
      final len = size.longestSide * (0.08 + rng.nextDouble() * 0.12) * amount;
      paint
        ..strokeWidth = 1 + rng.nextDouble() * 2.2
        ..color = Colors.white.withValues(alpha: 0.22 * amount);
      canvas.drawLine(c + dir * r0, c + dir * (r0 + len), paint);
    }
  }

  /// Red pulse at the edges when the next kick decides the match.
  static void tension(Canvas canvas, Size size, double amount, double clock) {
    if (amount <= 0.01) return;
    final beat = 0.55 + 0.45 * math.pow(math.sin(clock * math.pi * 1.6).abs(), 6);
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.radial(Offset(size.width / 2, size.height / 2), size.longestSide * 0.7, [
            const Color(0x00000000),
            Color.fromRGBO(190, 20, 20, 0.28 * amount * beat),
          ], const [
            0.62,
            1
          ]));
  }
}
