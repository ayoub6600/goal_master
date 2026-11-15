/// Keepy-uppy physics — a line-for-line twin of the server's
/// App\Services\Marketing\KeepyUppySimulator. The server replays the taps this
/// app records through its copy and only its count of touches counts, so the
/// two MUST stay in lock-step (test/features/games/keepy_sim_test.dart checks
/// this one against rounds recorded on the server):
///
/// - fixed 120 Hz steps; taps belong to a frame number, never to wall time;
/// - only + - * / on doubles, in the same order (no sqrt/sin in the loop);
/// - all inputs are integers (seed, millimetres, frames);
/// - one xorshift32 random stream, drawn in the same order.
///
/// Units: metres, seconds. x across the screen (0 = centre), y up from the
/// grass.
library;

class KeepyPhysics {
  const KeepyPhysics({
    required this.hz,
    required this.target,
    required this.gravityMm,
    required this.kickMm,
    required this.hitMm,
    required this.sideMm,
    required this.jitterMm,
    required this.windMm,
    required this.rampPermille,
    required this.halfWMm,
    required this.radiusMm,
    required this.startYMm,
    required this.startVyMm,
    required this.cooldownFrames,
    required this.maxFrames,
  });

  factory KeepyPhysics.fromJson(Map<String, dynamic> j) {
    int i(String k) => (j[k] as num).toInt();
    return KeepyPhysics(
      hz: i('hz'),
      target: i('target'),
      gravityMm: i('gravity_mm'),
      kickMm: i('kick_mm'),
      hitMm: i('hit_mm'),
      sideMm: i('side_mm'),
      jitterMm: i('jitter_mm'),
      windMm: i('wind_mm'),
      rampPermille: i('ramp_permille'),
      halfWMm: i('half_w_mm'),
      radiusMm: i('radius_mm'),
      startYMm: i('start_y_mm'),
      startVyMm: i('start_vy_mm'),
      cooldownFrames: i('cooldown_frames'),
      maxFrames: i('max_frames'),
    );
  }

  final int hz, target, gravityMm, kickMm, hitMm, sideMm, jitterMm, windMm;
  final int rampPermille, halfWMm, radiusMm, startYMm, startVyMm;
  final int cooldownFrames, maxFrames;

  double get hitRadius => hitMm / 1000.0;
  double get ballRadius => radiusMm / 1000.0;
  double get halfWidth => halfWMm / 1000.0;
}

/// One tap as it is sent to the server: the frame it landed on and where,
/// in whole millimetres.
class KeepyTap {
  const KeepyTap(this.frame, this.xMm, this.yMm);
  final int frame, xMm, yMm;

  List<int> toJson() => [frame, xMm, yMm];
}

enum KeepyEvent { none, touch, wall, won, lost }

class KeepySim {
  KeepySim(this.p, int seed)
      : _dt = 1.0 / p.hz,
        _g = p.gravityMm / 1000.0,
        _kick = p.kickMm / 1000.0,
        _hit = p.hitMm / 1000.0,
        _side = p.sideMm / 1000.0,
        _jitter = p.jitterMm / 1000.0,
        _windMax = p.windMm / 1000.0,
        _ramp = p.rampPermille / 1000.0,
        _halfW = p.halfWMm / 1000.0,
        _r = p.radiusMm / 1000.0,
        _state = (seed & 0xFFFFFFFF) == 0 ? 0x9E3779B9 : (seed & 0xFFFFFFFF),
        y = p.startYMm / 1000.0,
        vy = p.startVyMm / 1000.0 {
    _hit2 = _hit * _hit;
  }

  static const windSegment = 180;

  final KeepyPhysics p;
  final double _dt,
      _g,
      _kick,
      _hit,
      _side,
      _jitter,
      _windMax,
      _ramp,
      _halfW,
      _r;
  late final double _hit2;
  int _state;

  /// The next frame to be simulated.
  int frame = 0;
  double x = 0.0, y, vx = 0.0, vy;
  int touches = 0;
  int _last = -1000000;
  double _windFrom = 0.0, _windTo = 0.0;
  double wind = 0.0;
  bool finished = false, won = false;

  /// -1..1, how far off-centre the last touch was (for "perfect!" feedback).
  double lastOffset = 0;

  double _rand() {
    var s = _state;
    s ^= (s << 13) & 0xFFFFFFFF;
    s ^= s >> 17;
    s ^= (s << 5) & 0xFFFFFFFF;
    _state = s;
    return s / 4294967296.0;
  }

  /// Simulates frame [frame] with the taps that landed on it, in order.
  KeepyEvent step(List<KeepyTap> taps) {
    if (finished) return KeepyEvent.none;
    final i = frame;
    if (i >= p.maxFrames) {
      finished = true;
      return KeepyEvent.lost;
    }
    if (i % windSegment == 0) {
      _windFrom = _windTo;
      _windTo = (_rand() * 2.0 - 1.0) * _windMax;
    }
    wind = _windFrom + (_windTo - _windFrom) * ((i % windSegment) / 180.0);

    var event = KeepyEvent.none;
    for (final t in taps) {
      if (t.frame != i) continue;
      final tx = t.xMm / 1000.0;
      final ty = t.yMm / 1000.0;
      if (i - _last < p.cooldownFrames) continue;
      final dx = x - tx;
      final dy = y - ty;
      if (dx * dx + dy * dy > _hit2) continue;

      var off = dx / _hit;
      if (off > 1.0) off = 1.0;
      if (off < -1.0) off = -1.0;
      vy = _kick * (0.94 + 0.12 * _rand());
      vx = vx * 0.25 + off * _side + (_rand() * 2.0 - 1.0) * _jitter;
      touches++;
      _last = i;
      lastOffset = off;
      event = KeepyEvent.touch;
      if (touches >= p.target) {
        finished = true;
        won = true;
        return KeepyEvent.won;
      }
    }

    final k = touches < 40 ? touches : 40;
    vy = vy - _g * (1.0 + _ramp * k) * _dt;
    vx = (vx + wind * _dt) * 0.999;
    x = x + vx * _dt;
    y = y + vy * _dt;
    if (x > _halfW) {
      x = _halfW;
      vx = -vx * 0.6;
      if (event == KeepyEvent.none) event = KeepyEvent.wall;
    }
    if (x < -_halfW) {
      x = -_halfW;
      vx = -vx * 0.6;
      if (event == KeepyEvent.none) event = KeepyEvent.wall;
    }
    if (y <= _r) {
      finished = true;
      return KeepyEvent.lost;
    }
    frame = i + 1;
    return event;
  }

  /// Whole-round replay, exactly what the server runs on [taps].
  static ({int touches, int endFrame, bool won}) replay(
      KeepyPhysics p, int seed, List<KeepyTap> taps) {
    final sim = KeepySim(p, seed);
    var t = 0;
    while (!sim.finished) {
      final i = sim.frame;
      while (t < taps.length && taps[t].frame < i) {
        t++;
      }
      final start = t;
      while (t < taps.length && taps[t].frame == i) {
        t++;
      }
      sim.step(taps.sublist(start, t));
      if (sim.finished) {
        return (
          touches: sim.touches,
          endFrame: i >= p.maxFrames ? p.maxFrames : i,
          won: sim.won
        );
      }
    }
    return (touches: sim.touches, endFrame: sim.frame, won: sim.won);
  }
}
