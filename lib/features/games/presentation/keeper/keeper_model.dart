import 'dart:math' as math;

/// Mirror of the server's App\Services\Marketing\GoalkeeperModel: where the
/// keeper's gloves get to by the time the ball arrives. The server's verdict
/// is the one that counts; this only puts the gloves where it says they were.
///
/// Goal coordinates in metres: x across from the centre (posts at ±3.66),
/// y up from the grass (bar at 2.44).
abstract final class KeeperModel {
  static const halfWidth = 3.66;
  static const bar = 2.44;
  static const startX = 0.0;
  static const startY = 1.0;
  static const minReactMs = 160;
  static const launchMs = 100;
  static const speed = 5.6;
  static const reachX = 0.62;
  static const reachY = 0.48;

  /// Gloves [atMs] after the strike, for a dive toward [px],[py] that began
  /// [diveMs] after the strike (null: never dived).
  static ({double x, double y}) glove(double? px, double? py, int? diveMs, int atMs) {
    if (px == null || py == null || diveMs == null) return (x: startX, y: startY);
    px = px.clamp(-halfWidth - 0.3, halfWidth + 0.3);
    py = py.clamp(0.0, bar + 0.3);
    final dx = px - startX, dy = py - startY;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 1e-6) return (x: startX, y: startY);
    final moving = atMs - math.max(diveMs, minReactMs) - launchMs;
    final travel = math.max(0, moving) / 1000 * speed;
    final f = math.min(1.0, travel / dist);
    return (x: startX + dx * f, y: startY + dy * f);
  }

  static bool saved(double tx, double ty, double gx, double gy) {
    final nx = (tx - gx) / reachX, ny = (ty - gy) / reachY;
    return nx * nx + ny * ny <= 1.0;
  }
}
