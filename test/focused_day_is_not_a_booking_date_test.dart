import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `focusedDay` selects a night. It never dates a booking.
///
/// [CalendarCubit]'s `selectedDay`/`focusedDay` hold the OPERATIONAL NIGHT the
/// customer tapped — the night of Saturday 29 August, which runs past midnight
/// into Sunday 30 August. Every writer of it stores an operational date, and
/// `listTimeslot` sends it to the server as `operationalDate`.
///
/// The checkout screen used to submit that value as the booking's calendar
/// date while displaying the slot's real one a hundred lines above, so the
/// confirmation card said Sunday 30 August and the request said Saturday 29
/// August. On the monthly path the same value anchored the recurrence, turning
/// twelve Sundays into twelve Saturdays.
///
/// This is a structural test rather than a behavioural one on purpose: the
/// defect was a value read from the wrong place, and the only durable way to
/// stop it coming back is to assert that place is no longer read. It fails the
/// moment anyone reintroduces `focusedDay` into the submission path.
void main() {
  final checkout =
      File('lib/features/booking/presentation/view/booking_details.dart');

  /// Comments explain the bug on purpose; they are not the bug.
  List<String> codeLines(File file) {
    return file
        .readAsLinesSync()
        .where((l) => !l.trimLeft().startsWith('//'))
        .toList();
  }

  group('the checkout screen', () {
    test('exists where this test expects it', () {
      expect(checkout.existsSync(), isTrue);
    });

    test('never reads focusedDay', () {
      final offenders = codeLines(checkout)
          .where((l) => l.contains('focusedDay'))
          .toList();

      expect(
        offenders,
        isEmpty,
        reason: 'the booking date must come from the server-selected slot '
            '(selectedTime/start_at), not from the operational night',
      );
    });

    test('reads its dates through the authoritative occurrence', () {
      final source = checkout.readAsStringSync();

      expect(source, contains('BookingOccurrence'));
      expect(
        source,
        contains('occurrence.serviceDate'),
        reason: 'the submitted date is derived from the selected occurrence',
      );
      expect(
        source,
        contains('occurrence.startAtWire'),
        reason: 'the authoritative datetimes are sent for the server to '
            'cross-check the legacy triple against',
      );
    });

    test('has no fallback from a missing slot to a night', () {
      final source = checkout.readAsStringSync();

      // `?? focusedDay` in any shape would restore the exact defect under a
      // different name.
      expect(source.contains('?? calendar.focusedDay'), isFalse);
      expect(source.contains('?? state.focusedDay'), isFalse);
    });
  });

  group('the calendar cubit', () {
    final cubit = File(
        'lib/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart');

    test('sends the selected day only as an operational date', () {
      final source = cubit.readAsStringSync();

      expect(
        source,
        contains('operationalDate: formattedDate'),
        reason: 'the night is a listing key, not a booking date',
      );
      expect(
        source.contains('addDays') || source.contains('add(const Duration'),
        isFalse,
        reason: 'the cubit must never shift a date; the server decides which '
            'calendar day an after-midnight slot falls on',
      );
    });
  });
}
