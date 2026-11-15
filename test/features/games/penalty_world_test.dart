import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/games/presentation/penalty/penalty_world.dart';

void main() {
  final cam = PenaltyCamera(const Size(390, 844));

  List<SwipeSample> flick(Offset from, Offset to, {int ms = 160, double bow = 0}) => [
        for (var i = 0; i <= 8; i++)
          SwipeSample(
            Offset.lerp(from, to, i / 8)! + Offset(bow * math.sin(math.pi * i / 8), 0),
            (ms * i / 8).round(),
          ),
      ];

  group('camera', () {
    test('frames the goal wide and the ball low on a phone', () {
      final left = cam.project(const V3(-Pitch.halfGoal, 0, Pitch.goalLineZ));
      final right = cam.project(const V3(Pitch.halfGoal, 0, Pitch.goalLineZ));
      final bar = cam.project(const V3(0, Pitch.goalHeight, Pitch.goalLineZ));
      final ball = cam.project(Pitch.ballSpot);

      expect((right.dx - left.dx) / 390, closeTo(0.86, 0.02));
      expect(ball.dy / 844, closeTo(0.80, 0.01));
      expect(bar.dy, greaterThan(844 * 0.25), reason: 'room above the goal for the stands and HUD');
    });

    test('onPlane inverts project on the goal plane', () {
      const p = V3(-2.1, 1.7, Pitch.goalLineZ);
      final back = cam.onPlane(cam.project(p), Pitch.goalLineZ);
      expect(back.x, closeTo(p.x, 1e-9));
      expect(back.y, closeTo(p.y, 1e-9));
    });
  });

  group('swipe reader', () {
    final ball = cam.project(Pitch.ballSpot);

    test('a flick that ends on the top-left corner is aimed at the top-left corner', () {
      final corner = cam.project(const V3(-3.3, 2.2, Pitch.goalLineZ));
      final shot = SwipeReader.read(flick(ball, corner), cam)!;

      expect(shot.aim.x, closeTo((-3.3 / Pitch.goalWidth) + 0.5, 0.01));
      expect(shot.aim.y, closeTo(2.2 / Pitch.goalHeight, 0.01));
      expect(shot.aim.zone, 0);
    });

    test('a short flick stays low but keeps its direction', () {
      final target = cam.project(const V3(2.6, 1.0, Pitch.goalLineZ));
      final shortEnd = Offset.lerp(ball, target, 0.45)!;
      final shot = SwipeReader.read(flick(ball, shortEnd), cam)!;

      expect(shot.aim.y, lessThan(0.15));
      expect(shot.aim.x, greaterThan(0.5), reason: 'still to the right');
    });

    test('the flick can start anywhere; only its shape counts', () {
      final corner = cam.project(const V3(2.9, 0.4, Pitch.goalLineZ));
      final a = SwipeReader.read(flick(ball, corner), cam)!;
      final b = SwipeReader.read(flick(ball + const Offset(-60, 30), corner + const Offset(-60, 30)), cam)!;
      expect(b.aim.x, closeTo(a.aim.x, 1e-9));
      expect(b.aim.y, closeTo(a.aim.y, 1e-9));
    });

    test('taps, sideways and downward drags are not shots', () {
      expect(SwipeReader.read(flick(ball, ball + const Offset(10, -10)), cam), isNull);
      expect(SwipeReader.read(flick(ball, ball + const Offset(150, -5)), cam), isNull);
      expect(SwipeReader.read(flick(ball, ball + const Offset(0, 120)), cam), isNull);
    });

    test('a faster flick is a harder, quicker shot', () {
      final target = cam.project(const V3(1, 1, Pitch.goalLineZ));
      final slow = SwipeReader.read(flick(ball, target, ms: 420), cam)!;
      final fast = SwipeReader.read(flick(ball, target, ms: 70), cam)!;
      expect(fast.power, greaterThan(slow.power));
      expect(fast.flightSeconds, lessThan(slow.flightSeconds));
    });

    test('a bowed path becomes curl in the same direction', () {
      final target = cam.project(const V3(0, 1.2, Pitch.goalLineZ));
      expect(SwipeReader.read(flick(ball, target, bow: 40), cam)!.curl, greaterThan(0));
      expect(SwipeReader.read(flick(ball, target, bow: -40), cam)!.curl, lessThan(0));
    });

    test('a gentle shot is placed where it was aimed, a blast strays', () {
      const aim = ShotAim(0.2, 0.5);
      final rng = math.Random(1);
      double spread(double power) {
        var sum = 0.0;
        for (var i = 0; i < 400; i++) {
          final a = SwipeReader.withExecutionError(
              SwipeShot(aim: aim, curl: 0, flightSeconds: 0.6, power: power), 0.008, rng);
          sum += (a.x - aim.x).abs();
        }
        return sum / 400;
      }

      expect(spread(0), lessThan(0.012));
      expect(spread(1), greaterThan(spread(0) * 3));
    });
  });

  group('aim', () {
    test('uses the same 3x3 grid and woodwork band as the server', () {
      expect(const ShotAim(0.1, 0.9).zone, 0);
      expect(const ShotAim(0.9, 0.9).zone, 2);
      expect(const ShotAim(0.5, 0.5).zone, 4);
      expect(const ShotAim(0.1, 0.1).zone, 6);
      expect(const ShotAim(0.9, 0.1).zone, 8);
      expect(const ShotAim(0.01, 0.5).onWoodwork, isTrue);
      expect(const ShotAim(0.5, 1.01).onWoodwork, isTrue);
      expect(const ShotAim(1.08, 0.4).offTarget, isTrue);
      expect(const ShotAim(0.5, 0.5).offTarget || const ShotAim(0.5, 0.5).onWoodwork, isFalse);
    });
  });

  group('ball flight', () {
    test('leaves the spot and crosses the goal plane exactly at the aim', () {
      final f = BallFlight(aim: const ShotAim(0.85, 0.7), curl: 0.8, duration: 0.6);
      final start = f.at(0), atLine = f.at(0.6);
      expect(start.z, closeTo(0, 1e-9));
      expect(start.y, closeTo(Pitch.ballRadius, 1e-9));
      expect(atLine.x, closeTo(f.target.x, 1e-9));
      expect(atLine.y, closeTo(f.target.y, 1e-9));
      expect(atLine.z, closeTo(Pitch.goalLineZ, 1e-9));
      expect(f.at(0.3).x, greaterThan(f.target.x * 0.5), reason: 'curl bends it out mid-flight');
    });

    test('waits at the line until the outcome is known, then plays it out', () {
      final f = BallFlight(aim: const ShotAim(0.3, 0.3), curl: 0, duration: 0.5);
      expect(f.at(0.9).z, closeTo(Pitch.goalLineZ, 1e-9));

      f.outcome = KickOutcome.goal;
      expect(f.at(0.9).z, greaterThan(Pitch.goalLineZ + 1.0), reason: 'in the back of the net');

      f.outcome = KickOutcome.save;
      expect(f.at(0.9).z, lessThan(Pitch.goalLineZ), reason: 'parried back out');

      f.outcome = KickOutcome.post;
      expect(f.at(0.9).z, lessThan(Pitch.goalLineZ));
    });

    test('a bouncing ball never sinks below the grass', () {
      final f = BallFlight(aim: const ShotAim(0.02, 0.5), curl: 0, duration: 0.5)..outcome = KickOutcome.post;
      for (var t = 0.5; t < 4; t += 0.01) {
        expect(f.at(t).y, greaterThanOrEqualTo(Pitch.ballRadius - 1e-9));
      }
    });
  });

  group('keeper', () {
    for (final target in const [V3(-3.2, 2.1, 11), V3(3.0, 0.3, 11), V3(-2.5, 1.2, 11), V3(2.6, 1.9, 11)]) {
      test('a full dive puts the leading glove on $target', () {
        final k = KeeperMotion(reactAt: 0.1, arriveAt: 0.6)..diveTo(target, 0.2);
        final pose = k.at(0.6, 0);
        final arm = pose.frame == KeeperFrame.diveLeft ? KeeperSprite.leftGlove : KeeperSprite.rightGlove;
        final c = math.cos(pose.rotation), s = math.sin(pose.rotation);
        final glove = Offset(pose.centre.x + arm.dx * c - arm.dy * s, pose.centre.y + arm.dx * s + arm.dy * c);

        expect(pose.frame, target.x < 0 ? KeeperFrame.diveLeft : KeeperFrame.diveRight);
        expect((glove - Offset(target.x, target.y)).distance, lessThan(0.25));
      });
    }

    test('a shot at the keeper is met without diving', () {
      final k = KeeperMotion(reactAt: 0.1, arriveAt: 0.6)..diveTo(const V3(0.3, 1.0, 11), 0);
      expect(k.at(0.6, 0).frame, KeeperFrame.ready);
    });

    test('stays set on his line until he reacts', () {
      final k = KeeperMotion(reactAt: 0.2, arriveAt: 0.6)..diveTo(const V3(-3, 1, 11), 0);
      expect(k.at(0.1, 0).frame, KeeperFrame.ready);
      expect(k.at(0.1, 0).centre.x, closeTo(KeeperMotion.idleX(0), 1e-9));
    });
  });
}
