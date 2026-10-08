import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/databases/api/api_base_safety.dart';
import 'package:goal_master/core/databases/api/end_points.dart';

/// `EndPoints.baserUrl` is a `String.fromEnvironment` compile-time constant,
/// so a single test run can't vary it — `ApiBaseSafety` takes the URL as a
/// parameter instead, which is what's exercised against the various cases
/// below. The two tests against `EndPoints` itself cover its actual,
/// currently-baked-in value (the production default, since no --dart-define
/// is passed running `flutter test`).
void main() {
  group('ApiBaseSafety.releaseViolation', () {
    test('1. local dev default (127.0.0.1) is rejected for release', () {
      expect(ApiBaseSafety.releaseViolation('http://127.0.0.1:8000/api/'),
          isNotNull);
    });

    test('localhost by name is rejected for release', () {
      expect(
          ApiBaseSafety.releaseViolation('http://localhost:8000/api/'),
          isNotNull);
    });

    test('Android emulator loopback alias is rejected for release', () {
      expect(ApiBaseSafety.releaseViolation('http://10.0.2.2:8000/api/'),
          isNotNull);
    });

    test('a private-LAN address is rejected for release', () {
      expect(
          ApiBaseSafety.releaseViolation('http://192.168.1.50:8000/api/'),
          isNotNull);
    });

    test('a private-LAN address is rejected even over https', () {
      expect(ApiBaseSafety.releaseViolation('https://192.168.1.50/api/'),
          isNotNull);
    });

    test('a plain-http public host is rejected — HTTPS required', () {
      expect(
          ApiBaseSafety.releaseViolation('http://web.goalmasters.online/api/'),
          isNotNull);
    });

    test('4. the real production HTTPS API is accepted', () {
      expect(
          ApiBaseSafety.releaseViolation('https://web.goalmasters.online/api/'),
          isNull);
    });
  });

  group('EndPoints (actual compiled-in value)', () {
    test(
        '1. the production default is safe to ship with no --dart-define '
        'at all',
        () {
      expect(EndPoints.baserUrl, 'https://goalmaster.aljidartech.com/api/');
      expect(EndPoints.isLocalApi, isFalse);
    });

    test(
        '2. building with no --dart-define=API_BASE at all is NOT flagged '
        '— the default is already the real production host',
        () {
      // Nobody passed API_BASE, so the compile-time default (production) is
      // what's baked in — and it must be accepted, not refused. The guard
      // this pins is the opposite failure mode from before: an unconfigured
      // build must still be safe to ship, never silently local.
      expect(EndPoints.releaseSafetyViolation, isNull);
    });
  });
}
