import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/booking/domain/booking_occurrence.dart';

/// The booked date comes from the server's slot, never from the night.
///
/// Goal Master lets a customer pick an OPERATIONAL NIGHT — «الليلة» — which
/// runs past midnight into the next calendar day. Selecting 00:00–01:00 on the
/// night of Saturday 29 August books Sunday 30 August. The app used to submit
/// the night instead of the slot, so that booking went in as Saturday 29
/// August: one day early on the normal path, and twelve Saturdays instead of
/// twelve Sundays on the monthly one.
///
/// `focusedDay` selects which night to list. It is not a booking date, and
/// these tests exist so it never becomes one again.
void main() {
  // The night the customer tapped. Every assertion below must be free of it.
  final operationalNight = DateTime(2026, 8, 29);

  group('after-midnight slots keep the server\'s calendar date', () {
    test('00:00–01:00 on the night of 29 Aug is booked as 30 Aug', () {
      final occurrence = BookingOccurrence.tryFrom(
        DateTime(2026, 8, 30, 0, 0),
        DateTime(2026, 8, 30, 1, 0),
      )!;

      expect(occurrence.serviceDate, '2026-08-30');
      expect(occurrence.startTime, '00:00:00');
      expect(occurrence.endTime, '01:00:00');
      expect(occurrence.serviceDate, isNot('2026-08-29'));
    });

    test('01:00–02:00 on the same night is also 30 Aug', () {
      final occurrence = BookingOccurrence.tryFrom(
        DateTime(2026, 8, 30, 1, 0),
        DateTime(2026, 8, 30, 2, 0),
      )!;

      expect(occurrence.serviceDate, '2026-08-30');
      expect(occurrence.startTime, '01:00:00');
      expect(occurrence.endTime, '02:00:00');
    });

    test('30 Aug 2026 is a Sunday, which is what the customer is shown', () {
      final occurrence = BookingOccurrence.tryFrom(
        DateTime(2026, 8, 30, 0, 0),
        DateTime(2026, 8, 30, 1, 0),
      )!;

      expect(occurrence.startAt.weekday, DateTime.sunday);
      // The night it belongs to is a Saturday. Both are true; only one of
      // them is the booking date.
      expect(operationalNight.weekday, DateTime.saturday);
    });
  });

  group('a slot that crosses midnight', () {
    test('29 Aug 23:00 → 30 Aug 00:00 is dated by its START', () {
      final occurrence = BookingOccurrence.tryFrom(
        DateTime(2026, 8, 29, 23, 0),
        DateTime(2026, 8, 30, 0, 0),
      )!;

      // The night you play on is the night you start.
      expect(occurrence.serviceDate, '2026-08-29');
      expect(occurrence.startTime, '23:00:00');
      expect(occurrence.endTime, '00:00:00');
      expect(occurrence.crossesMidnight, isTrue);

      // The wire form keeps the day the legacy clocks cannot express.
      expect(occurrence.startAtWire, '2026-08-29 23:00:00');
      expect(occurrence.endAtWire, '2026-08-30 00:00:00');
    });

    test('an evening slot inside one day does not claim to cross midnight', () {
      final occurrence = BookingOccurrence.tryFrom(
        DateTime(2026, 8, 29, 19, 0),
        DateTime(2026, 8, 29, 20, 0),
      )!;

      expect(occurrence.crossesMidnight, isFalse);
      expect(occurrence.serviceDate, '2026-08-29');
    });
  });

  group('the monthly anchor', () {
    test('recurs on Sundays from 30 Aug, never from the 29th', () {
      final occurrence = BookingOccurrence.tryFrom(
        DateTime(2026, 8, 30, 0, 0),
        DateTime(2026, 8, 30, 1, 0),
      )!;

      // The server steps +7 days from whatever anchor it is handed.
      final series = List.generate(
        4,
        (i) => occurrence.startAt.add(Duration(days: 7 * i)),
      );

      expect(
        series.map((d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-'
            '${d.day.toString().padLeft(2, '0')}'),
        ['2026-08-30', '2026-09-06', '2026-09-13', '2026-09-20'],
      );
      expect(series.every((d) => d.weekday == DateTime.sunday), isTrue);
      expect(series.first, isNot(operationalNight));
    });
  });

  midnightDurationContract();

  group('no silent fallback', () {
    test('returns null before a slot has been selected', () {
      expect(BookingOccurrence.tryFrom(null, null), isNull);
      expect(
        BookingOccurrence.tryFrom(DateTime(2026, 8, 30), null),
        isNull,
        reason: 'half an occurrence must not be treated as a whole one',
      );
    });

    test('accepts the string form the server sends', () {
      final occurrence = BookingOccurrence.tryFrom(
        '2026-08-30 00:00:00',
        '2026-08-30 01:00:00',
      )!;

      expect(occurrence.serviceDate, '2026-08-30');
    });
  });
}

/// The client-side "at least an hour" check, reproduced.
///
/// It lives in AddBookingCubit and is unreachable from a unit test without a
/// repository, so the arithmetic it depends on is pinned here instead: a
/// midnight-crossing booking is an hour long, and only real timestamps can
/// say so. Read as two bare clocks, 23:00 → 00:00 is minus twenty-three
/// hours and the booking is refused for being too short.
void midnightDurationContract() {
  test('23:00 → 00:00 is one hour when measured on the occurrence', () {
    final occurrence = BookingOccurrence.tryFrom(
      DateTime(2026, 8, 29, 23, 0),
      DateTime(2026, 8, 30, 0, 0),
    )!;

    expect(occurrence.endAt.difference(occurrence.startAt).inMinutes, 60);

    // The same pair as clocks, which is what a HH:mm:ss parse would give.
    final asClocks = DateTime(1970, 1, 1, 0, 0)
        .difference(DateTime(1970, 1, 1, 23, 0))
        .inMinutes;
    expect(asClocks, lessThan(60),
        reason: 'this is why the check must not be given clock strings');
  });
}
