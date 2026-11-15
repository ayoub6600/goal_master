import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_sim.dart';

/// Rounds recorded by the server's KeepyUppySimulator (bot play on every
/// tier plus random tap storms). The server decides keepy-uppy by replaying
/// the app's taps, so the app's simulator must agree with it to the frame —
/// otherwise a player sees a touch the server doesn't count.
///
/// Regenerate after any physics change on the server:
///   php -d error_reporting=0 <scratch>/golden.php > test/features/games/fixtures/keepy_golden.json
void main() {
  final cases = (jsonDecode(
          File('test/features/games/fixtures/keepy_golden.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  test('fixture covers wins, losses and every tier', () {
    expect(cases.length, greaterThanOrEqualTo(15));
    expect(cases.where((c) => c['won'] == true), isNotEmpty);
    expect(cases.where((c) => c['won'] == false), isNotEmpty);
  });

  for (var i = 0; i < cases.length; i++) {
    final c = cases[i];
    test('case $i matches the server to the frame', () {
      final p = KeepyPhysics.fromJson(Map<String, dynamic>.from(c['params'] as Map));
      final taps = (c['taps'] as List)
          .map((t) => KeepyTap((t[0] as num).toInt(), (t[1] as num).toInt(), (t[2] as num).toInt()))
          .toList();

      final r = KeepySim.replay(p, (c['seed'] as num).toInt(), taps);

      expect(r.touches, c['touches']);
      expect(r.endFrame, c['end_frame']);
      expect(r.won, c['won']);
    });
  }

  test('frame-by-frame live play equals the whole-round replay', () {
    final c = cases[4];
    final p = KeepyPhysics.fromJson(Map<String, dynamic>.from(c['params'] as Map));
    final taps = (c['taps'] as List)
        .map((t) => KeepyTap((t[0] as num).toInt(), (t[1] as num).toInt(), (t[2] as num).toInt()))
        .toList();
    final sim = KeepySim(p, (c['seed'] as num).toInt());
    var touchEvents = 0;
    while (!sim.finished) {
      final e = sim.step(taps.where((t) => t.frame == sim.frame).toList());
      if (e == KeepyEvent.touch || e == KeepyEvent.won) touchEvents++;
    }
    expect(sim.touches, c['touches']);
    expect(touchEvents, c['touches']);
  });
}
