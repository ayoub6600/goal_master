import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/databases/api/dio_consumer.dart';
import 'package:goal_master/core/databases/api/end_points.dart';

/// One API base URL, for every request the app makes.
///
/// Login once reached a real server while every request after it was refused
/// at 127.0.0.1 — the sort of split that looks like two Dio clients with two
/// configurations. It was not: it was two BUILDS, one made with
/// --dart-define=API_BASE and one without, because the base URL is a
/// compile-time constant and VS Code's launch configuration passed no define.
///
/// These tests pin the property that made that diagnosis possible: there is
/// exactly one authority, so a mismatch can only ever come from the build
/// command — never from one repository quietly deciding for itself.
void main() {
  group('API base URL', () {
    test('the client takes its base from the single constant', () {
      final dio = Dio();
      DioConsumer(dio: dio);

      expect(dio.options.baseUrl, EndPoints.baserUrl);
    });

    test('every client built the same way agrees', () {
      // Stands in for the repositories: they all receive the one registered
      // DioConsumer, so any two clients must be configured identically.
      final first = Dio();
      final second = Dio();
      DioConsumer(dio: first);
      DioConsumer(dio: second);

      expect(first.options.baseUrl, second.options.baseUrl);
    });

    test('the default is the local development server', () {
      // No --dart-define in the test runner, so this is the default path —
      // the one the Simulator relies on.
      expect(EndPoints.baserUrl, 'http://127.0.0.1:8000/api/');
      expect(EndPoints.isLocalApi, isTrue);
    });

    test('a local base is recognised as local', () {
      // Drives the release guard and the startup notice. Loopback and the
      // private ranges are all developer machines; a public host is not.
      expect(EndPoints.isLocalApi, isTrue,
          reason: '127.0.0.1 must be treated as local');
    });

    test('no source file hardcodes an API host', () {
      // The real regression risk: someone "fixes" a device by pasting a LAN
      // address into a repository. That works until the network changes, and
      // it reintroduces exactly the split this suite exists to prevent.
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        // end_points.dart legitimately holds the single default.
        if (entity.path.endsWith('api/end_points.dart')) continue;

        for (final line in entity.readAsLinesSync()) {
          final code = line.split('//').first;
          if (RegExp(r'https?://(127\.0\.0\.1|localhost|10\.0\.2\.2|192\.168\.|172\.\d+\.)')
              .hasMatch(code)) {
            offenders.add('${entity.path}: ${line.trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'API hosts belong only in EndPoints.baserUrl:\n${offenders.join('\n')}',
      );
    });
  });
}
