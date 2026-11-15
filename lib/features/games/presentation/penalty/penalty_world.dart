import 'dart:math' as math;
import 'dart:ui';

/// World units are metres. x runs across the goal (0 = centre, + = right as
/// the shooter sees it), y is up from the grass, z runs from the penalty spot
/// (z = 0) towards the goal line (z = 11).
class V3 {
  const V3(this.x, this.y, this.z);
  final double x, y, z;

  V3 operator +(V3 o) => V3(x + o.x, y + o.y, z + o.z);
  V3 operator -(V3 o) => V3(x - o.x, y - o.y, z - o.z);
  V3 operator *(double k) => V3(x * k, y * k, z * k);

  static V3 lerp(V3 a, V3 b, double t) =>
      V3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);

  @override
  String toString() =>
      'V3(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})';
}

abstract final class Pitch {
  static const goalWidth = 7.32;
  static const goalHeight = 2.44;
  static const halfGoal = goalWidth / 2;
  static const goalLineZ = 11.0;
  static const ballRadius = 0.11;
  static const keeperZ = 10.85;
  static const ballSpot = V3(0, ballRadius, 0);

  /// Must match PenaltyKickResolver::WOODWORK_BAND on the server.
  static const woodworkBand = 0.025;

  /// The back net runs from 2.0 m behind the line at the grass to 0.9 m at
  /// its top edge (netTop); the roof joins that edge to the crossbar.
  static const netTop = 2.2;
  static double netDepthAt(double y) =>
      2.0 - (y.clamp(0, netTop) / netTop) * 1.1;
}

/// A pinhole camera standing behind the penalty spot.
class PenaltyCamera {
  PenaltyCamera(this.size, {double dolly = 0, this.shake = Offset.zero})
      : z = _baseZ + dolly,
        focal = math.min(1.563 * size.width, 0.95 * size.height) {
    horizon = size.height * 0.80 - focal * (y - Pitch.ballRadius) / -_baseZ;
  }

  static const _baseZ = -2.3;
  final Size size;
  final double x = 0, y = 1.25, z;
  final double focal;
  final Offset shake;
  late final double horizon;

  double get cx => size.width / 2 + shake.dx;
  double get _h => horizon + shake.dy;

  double scaleAt(double worldZ) => focal / math.max(0.05, worldZ - z);

  Offset project(V3 p) {
    final s = scaleAt(p.z);
    return Offset(cx + (p.x - x) * s, _h - (p.y - y) * s);
  }

  /// Inverse of [project] for a screen point lying on the plane z = [worldZ].
  V3 onPlane(Offset screen, double worldZ) {
    final d = math.max(0.05, worldZ - z);
    return V3(x + (screen.dx - cx) * d / focal, y - (screen.dy - _h) * d / focal,
        worldZ);
  }
}

/// Where the ball crosses the goal plane, normalised: x 0..1 is post to
/// post, y 0..1 is grass to crossbar. Values outside are off target.
class ShotAim {
  const ShotAim(this.x, this.y);
  final double x, y;

  V3 get world => V3((x - 0.5) * Pitch.goalWidth, y * Pitch.goalHeight,
      Pitch.goalLineZ);

  bool get offTarget =>
      x < -Pitch.woodworkBand ||
      x > 1 + Pitch.woodworkBand ||
      y > 1 + Pitch.woodworkBand;

  bool get onWoodwork =>
      !offTarget &&
      (x.abs() <= Pitch.woodworkBand ||
          (x - 1).abs() <= Pitch.woodworkBand ||
          (y - 1).abs() <= Pitch.woodworkBand);

  /// Same 3×3 grid as PenaltyKickResolver::zoneFor — row 0 is the top.
  int get zone {
    final col = x < 1 / 3 ? 0 : (x < 2 / 3 ? 1 : 2);
    final row = y >= 2 / 3 ? 0 : (y >= 1 / 3 ? 1 : 2);
    return row * 3 + col;
  }

  static V3 zoneCentre(int zone) {
    final col = zone % 3, row = zone ~/ 3;
    return V3(const [-2.45, 0.0, 2.45][col], const [1.95, 1.2, 0.4][row],
        Pitch.goalLineZ);
  }
}

class SwipeSample {
  const SwipeSample(this.position, this.ms);
  final Offset position;
  final int ms;
}

/// What a flick of the finger means as a shot, before execution error.
class SwipeShot {
  const SwipeShot({
    required this.aim,
    required this.curl,
    required this.flightSeconds,
    required this.power,
  });

  final ShotAim aim;

  /// Signed sideways bend at mid-flight in metres (+ bends right).
  final double curl;
  final double flightSeconds;

  /// 0 for a gentle side-foot, 1 for a full-blooded strike.
  final double power;
}

abstract final class SwipeReader {
  static const minLength = 55.0;

  /// The finger draws the shot from the ball: the flick's direction picks
  /// the side, how far up the screen it reaches picks the height (so a flick
  /// that ends on the top corner goes to the top corner), its speed picks
  /// the pace, and any bow in the path becomes curl.
  static SwipeShot? read(List<SwipeSample> samples, PenaltyCamera cam) {
    if (samples.length < 2) return null;
    final start = samples.first.position, end = samples.last.position;
    final chord = end - start;
    if (chord.distance < minLength || chord.dy > -minLength * 0.6) return null;

    final ball = cam.project(Pitch.ballSpot);
    final virtual = ball + chord;
    final onGoal = cam.onPlane(virtual, Pitch.goalLineZ);

    // A short flick still travels along its line; it just stays low.
    final height = math.max(onGoal.y, 0.12);
    final sy = cam.project(V3(0, height, Pitch.goalLineZ)).dy;
    final t = (sy - ball.dy) / (virtual.dy - ball.dy);
    final sx = ball.dx + t * (virtual.dx - ball.dx);
    final worldX = cam.onPlane(Offset(sx, sy), Pitch.goalLineZ).x;

    var bow = 0.0;
    final len = chord.distance;
    for (final s in samples) {
      final d = s.position - start;
      final side = (chord.dx * d.dy - chord.dy * d.dx) / len;
      if (side.abs() > bow.abs()) bow = side;
    }
    final curl = (bow / len).clamp(-0.45, 0.45) * 3.0;

    final speed = _releaseSpeed(samples) / cam.size.height; // screens/second
    final power = ((speed - 1.2) / 4.0).clamp(0.0, 1.0);
    final flight = (1.0 - 0.1 * speed).clamp(0.42, 0.9);

    return SwipeShot(
      aim: ShotAim(worldX / Pitch.goalWidth + 0.5, height / Pitch.goalHeight),
      curl: curl,
      flightSeconds: flight,
      power: power,
    );
  }

  static double _releaseSpeed(List<SwipeSample> samples) {
    final last = samples.last;
    var i = samples.length - 1;
    while (i > 0 && last.ms - samples[i - 1].ms <= 80) {
      i--;
    }
    if (i == samples.length - 1 && i > 0) i--;
    final first = samples[i];
    final ms = math.max(8, last.ms - first.ms);
    return (last.position - first.position).distance / ms * 1000;
  }

  /// Real strikers miss: the harder they hit it the more it strays, and a
  /// laces-through strike tends to rise.
  static ShotAim withExecutionError(
      SwipeShot shot, double difficultySpread, math.Random rng) {
    double gauss() {
      final u = math.max(1e-9, rng.nextDouble()), v = rng.nextDouble();
      return math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v);
    }

    final spread = difficultySpread + math.pow(shot.power, 3) * 0.04;
    return ShotAim(
      shot.aim.x + gauss() * spread,
      shot.aim.y + gauss() * spread * 0.8 + shot.power * shot.power * 0.07,
    );
  }
}

enum KickOutcome { goal, save, post, miss }

KickOutcome outcomeFrom(String value) => switch (value) {
      'goal' => KickOutcome.goal,
      'save' => KickOutcome.save,
      'post' => KickOutcome.post,
      _ => KickOutcome.miss,
    };

/// The ball's whole path for one kick as a pure function of time, so the
/// live kick and its slow-motion replay are frame-for-frame identical.
class BallFlight {
  BallFlight({required this.aim, required this.curl, required this.duration})
      : target = aim.world {
    lift = 0.12 + 0.35 * ((duration - 0.42) / 0.48).clamp(0, 1);
  }

  final ShotAim aim;
  final V3 target;
  final double curl, duration;
  late final double lift;
  KickOutcome? outcome;

  /// Set for saves: the parry direction, decided once the keeper is known.
  double parrySide = 1;
  bool caught = false;

  static const _gravity = 9.81;

  V3 _pre(double u) {
    final bow = 4 * u * (1 - u);
    return V3(
      target.x * u + curl * bow,
      Pitch.ballRadius + (target.y - Pitch.ballRadius) * u + lift * bow,
      Pitch.goalLineZ * u * (1.12 - 0.12 * u),
    );
  }

  V3 get _planeVelocity {
    const du = 0.02;
    return (_pre(1) - _pre(1 - du)) * (1 / (du * duration));
  }

  V3 at(double t) {
    if (t <= duration || outcome == null) {
      return _pre((t / duration).clamp(0.0, 1.0));
    }
    final s = t - duration;
    final hit = _pre(1);
    final v = _planeVelocity;
    switch (outcome!) {
      case KickOutcome.goal:
        final depth = Pitch.netDepthAt(hit.y) + 0.25;
        final k = 1 - math.exp(-s / 0.07);
        final drop = math.max(0, s - 0.14);
        return V3(
          hit.x + v.x * 0.07 * k,
          math.max(Pitch.ballRadius,
              hit.y - 0.5 * _gravity * drop * drop + v.y * 0.05 * k),
          hit.z + depth * k,
        );
      case KickOutcome.save:
        if (caught) return hit;
        return _bouncing(hit, V3(parrySide * 5.5, 2.6, -4.5), s);
      case KickOutcome.post:
        final bar = (aim.y - 1).abs() <= Pitch.woodworkBand;
        final out = aim.x < 0.5 ? -1.0 : 1.0;
        return _bouncing(hit, bar ? V3(v.x * 0.3, 4.2, -5.5) : V3(out * 3.2, 1.2, -6.5), s);
      case KickOutcome.miss:
        final p = hit + V3(v.x, v.y, v.z) * s;
        final boards = Pitch.goalLineZ + 4.2;
        if (p.y < 0.9 && p.z > boards) {
          final back = p.z - boards;
          return V3(p.x, p.y, boards - back * 0.25);
        }
        return V3(p.x, math.max(Pitch.ballRadius, p.y - 0.5 * _gravity * s * s * 0.4), p.z);
    }
  }

  static V3 _bouncing(V3 from, V3 v, double s) {
    var p = from, vel = v;
    var remaining = s;
    for (var bounce = 0; bounce < 4 && remaining > 0; bounce++) {
      // Time until this arc lands back on the grass.
      final a = 0.5 * _gravity, b = -vel.y, c = -(p.y - Pitch.ballRadius);
      final land = (-b + math.sqrt(math.max(0, b * b - 4 * a * c))) / (2 * a);
      if (remaining < land) {
        return V3(p.x + vel.x * remaining,
            p.y + vel.y * remaining - a * remaining * remaining,
            p.z + vel.z * remaining);
      }
      p = V3(p.x + vel.x * land, Pitch.ballRadius, p.z + vel.z * land);
      final vy = vel.y - _gravity * land;
      vel = V3(vel.x * 0.7, -vy * 0.45, vel.z * 0.7);
      remaining -= land;
    }
    return V3(p.x + vel.x * 0.3, Pitch.ballRadius, p.z + vel.z * 0.3);
  }
}

enum KeeperFrame { ready, diveLeft, diveRight }

class KeeperPose {
  const KeeperPose(this.centre, this.frame, this.rotation);

  /// Centre of the sprite's bounding box, in world metres.
  final V3 centre;
  final KeeperFrame frame;

  /// Radians, counter-clockwise in world space (y up).
  final double rotation;
}

/// Sprite geometry measured from football_keeper_strip.webp.
abstract final class KeeperSprite {
  static const pxPerMetre = 319.0;
  static const ready = Rect.fromLTWH(28, 92, 460, 568);
  static const diveLeft = Rect.fromLTWH(468, 180, 832, 352);
  static const diveRight = Rect.fromLTWH(1324, 196, 836, 344);

  /// Leading glove relative to the frame centre, world metres (y up).
  static const leftGlove = Offset(-1.14, 0.31);
  static const rightGlove = Offset(1.14, 0.24);
  static const standingHeight = 568 / pxPerMetre;
}

/// The goalkeeper's movement for one kick, also a pure function of time.
class KeeperMotion {
  KeeperMotion({required this.reactAt, required this.arriveAt});

  final double reactAt, arriveAt;
  V3? _gloveTarget;
  KeeperFrame _frame = KeeperFrame.ready;
  double _rotation = 0, _jump = 0;
  V3 _end = const V3(0, KeeperSprite.standingHeight / 2, Pitch.keeperZ);
  double _startX = 0;

  static double idleX(double clock) =>
      0.3 * math.sin(clock * 1.7) + 0.1 * math.sin(clock * 4.1);

  /// On his line, shuffling side to side and bouncing on his toes.
  static KeeperPose idle(double clock) => KeeperPose(
      V3(idleX(clock),
          KeeperSprite.standingHeight / 2 + 0.03 * math.sin(clock * 6),
          Pitch.keeperZ),
      KeeperFrame.ready,
      0);

  /// Commits the dive. [glove] is where the leading hand should end up.
  void diveTo(V3 glove, double startX) {
    _startX = startX;
    _gloveTarget = glove;
    final dx = glove.x - startX;
    if (dx.abs() < 1.0) {
      _frame = KeeperFrame.ready;
      _jump = (glove.y - 1.55).clamp(0.0, 0.75);
      _end = V3(startX + dx * 0.6, KeeperSprite.standingHeight / 2 + _jump,
          Pitch.keeperZ);
      return;
    }
    final left = dx < 0;
    _frame = left ? KeeperFrame.diveLeft : KeeperFrame.diveRight;
    final arm = left ? KeeperSprite.leftGlove : KeeperSprite.rightGlove;
    final want = math.atan2(glove.y - 0.95, dx);
    final base = math.atan2(arm.dy, arm.dx);
    var rot = want - base;
    while (rot > math.pi) {
      rot -= 2 * math.pi;
    }
    while (rot < -math.pi) {
      rot += 2 * math.pi;
    }
    _rotation = rot.clamp(-0.7, 0.7);
    final c = math.cos(_rotation), s = math.sin(_rotation);
    final ax = arm.dx * c - arm.dy * s, ay = arm.dx * s + arm.dy * c;
    _end = V3(glove.x - ax, math.max(0.42, glove.y - ay), Pitch.keeperZ);
  }

  bool get committed => _gloveTarget != null;

  KeeperPose at(double t, double clock) {
    final ready = V3(idleX(clock), KeeperSprite.standingHeight / 2 +
        0.03 * math.sin(clock * 6), Pitch.keeperZ);
    if (_gloveTarget == null || t < reactAt) {
      return KeeperPose(ready, KeeperFrame.ready, 0);
    }
    final start = V3(_startX, KeeperSprite.standingHeight / 2, Pitch.keeperZ);
    final u = ((t - reactAt) / math.max(0.05, arriveAt - reactAt)).clamp(0.0, 1.0);
    final e = 1 - math.pow(1 - u, 2.2).toDouble();

    if (_frame == KeeperFrame.ready) {
      final up = math.sin(u * math.pi * 0.5) * _jump;
      final f = math.max(0.0, t - arriveAt);
      final fall = math.min(_jump, 0.5 * 9.8 * f * f);
      return KeeperPose(
          V3(start.x + (_end.x - start.x) * e,
              KeeperSprite.standingHeight / 2 + up - fall, Pitch.keeperZ),
          KeeperFrame.ready,
          0);
    }

    // Load the legs for the first instant, then fly.
    if (u < 0.12) {
      return KeeperPose(
          V3(start.x + (_end.x - start.x) * 0.04,
              start.y - 0.08 * (u / 0.12), Pitch.keeperZ),
          KeeperFrame.ready,
          (_frame == KeeperFrame.diveLeft ? 0.12 : -0.12) * (u / 0.12));
    }
    final arc = math.sin(e * math.pi) * 0.18;
    var centre = V3(start.x + (_end.x - start.x) * e,
        start.y + (_end.y - start.y) * e + arc, Pitch.keeperZ);
    var rot = _rotation * e;
    if (t > arriveAt) {
      // Gravity wins: the keeper comes down onto the grass.
      final f = t - arriveAt;
      final drop = math.min(centre.y - 0.3, 0.5 * 9.8 * f * f);
      centre = V3(centre.x + (_end.x - start.x).sign * f * 0.6,
          centre.y - drop, centre.z);
      rot = rot * math.max(0, 1 - f * 2.5);
    }
    return KeeperPose(centre, _frame, rot);
  }
}

/// A short damped wave travelling through the net from where the ball hit.
class NetRipple {
  const NetRipple(this.at, this.start, this.strength);
  final V3 at;
  final double start, strength;

  double push(double x, double y, double t) {
    final s = t - start;
    if (s < 0) return 0;
    final d2 = (x - at.x) * (x - at.x) + (y - at.y) * (y - at.y);
    final d = math.sqrt(d2);
    return strength *
        math.exp(-d2 / 0.9) *
        math.exp(-s / 0.55) *
        math.cos(s * 16 - d * 5) *
        math.min(1, s / 0.04);
  }
}
