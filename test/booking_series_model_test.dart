import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';

/// The group card must never call `series.occurrences.first` a status, nor
/// invent a financial total on the device. These pin the two rules that keep
/// it honest: `nextOccurrence` is derived from date and cancellation state —
/// never sequence order alone — and the payment fields are read straight off
/// the server's own `PaymentState` output, with a defined fallback only for a
/// server build that predates them.
void main() {
  Map<String, dynamic> occurrenceJson({
    required int bookingId,
    required int sequence,
    required String date,
    int status = 2,
    bool isReplacement = false,
  }) =>
      {
        'booking_id': bookingId,
        'sequence': sequence,
        'date': date,
        'start_time': '20:00:00',
        'end_time': '21:00:00',
        'status': status,
        'status_name': 'موافق عليه',
        'can_cancel': status == 2,
        'is_replacement': isReplacement,
      };

  Map<String, dynamic> seriesJson({
    List<Map<String, dynamic>> occurrences = const [],
    Map<String, dynamic> overrides = const {},
  }) =>
      {
        'series_id': 100002,
        'status': 'active',
        'status_label': 'نشط',
        'occurrence_count': occurrences.length,
        'start_date': '2026-08-30',
        'end_date': '2026-09-20',
        'day_of_week': 0,
        'day_name': 'الأحد',
        'start_time': '20:00:00',
        'end_time': '21:00:00',
        'branch': 'ملاعب الجدار',
        'price_per_occurrence': 66,
        'total_amount': 264,
        'can_cancel_all': false,
        'occurrences': occurrences,
        ...overrides,
      };

  group('nextOccurrence is deterministic, never the first row blindly', () {
    test('picks the earliest date that is neither past nor cancelled', () {
      final series = BookingSeries.fromJson(seriesJson(occurrences: [
        occurrenceJson(bookingId: 100024, sequence: 1, date: '2026-08-30'),
        occurrenceJson(bookingId: 100025, sequence: 2, date: '2026-09-06'),
        occurrenceJson(bookingId: 100026, sequence: 3, date: '2026-09-13'),
        occurrenceJson(bookingId: 100027, sequence: 4, date: '2026-09-20'),
      ]));

      final next = series.nextOccurrence(DateTime(2026, 9, 8));
      expect(next!.bookingId, 100026);
      expect(next.date, '2026-09-13');
    });

    test('a cancelled first date is skipped, not frozen on', () {
      final series = BookingSeries.fromJson(seriesJson(occurrences: [
        occurrenceJson(
          bookingId: 100024,
          sequence: 1,
          date: '2026-09-06',
          status: 3, // cancelled
        ),
        occurrenceJson(bookingId: 100025, sequence: 2, date: '2026-09-13'),
      ]));

      final next = series.nextOccurrence(DateTime(2026, 9, 1));
      expect(next!.bookingId, 100025);
    });

    test('a finished series reports null, never an old date', () {
      final series = BookingSeries.fromJson(seriesJson(occurrences: [
        occurrenceJson(bookingId: 100024, sequence: 1, date: '2026-08-30'),
        occurrenceJson(bookingId: 100025, sequence: 2, date: '2026-09-06'),
      ]));

      expect(series.nextOccurrence(DateTime(2026, 10, 1)), isNull);
    });

    test('a session happening today still counts as next', () {
      final series = BookingSeries.fromJson(seriesJson(occurrences: [
        occurrenceJson(bookingId: 100024, sequence: 1, date: '2026-09-13'),
      ]));

      expect(
        series.nextOccurrence(DateTime(2026, 9, 13, 23, 0))!.bookingId,
        100024,
      );
    });

    test('order in the payload does not matter — a replacement can arrive '
        'out of sequence', () {
      final series = BookingSeries.fromJson(seriesJson(occurrences: [
        occurrenceJson(bookingId: 100027, sequence: 4, date: '2026-09-20'),
        occurrenceJson(
          bookingId: 100025,
          sequence: 2,
          date: '2026-09-06',
          isReplacement: true,
        ),
      ]));

      expect(
        series.nextOccurrence(DateTime(2026, 9, 1))!.bookingId,
        100025,
      );
    });
  });

  group('counts are read from the occurrences actually returned', () {
    test('played and cancelled are counted, not assumed from status label',
        () {
      final series = BookingSeries.fromJson(seriesJson(occurrences: [
        occurrenceJson(bookingId: 1, sequence: 1, date: '2026-08-01', status: 4),
        occurrenceJson(bookingId: 2, sequence: 2, date: '2026-08-08', status: 4),
        occurrenceJson(bookingId: 3, sequence: 3, date: '2026-08-15', status: 3),
        occurrenceJson(bookingId: 4, sequence: 4, date: '2026-08-22', status: 2),
      ]));

      expect(series.playedCount, 2);
      expect(series.cancelledCount, 1);
      expect(series.activeCount, 3); // total minus cancelled
    });
  });

  group('payment fields are the server\'s own PaymentState output', () {
    test('reads paid/remaining/status straight through', () {
      final series = BookingSeries.fromJson(seriesJson(overrides: {
        'paid_amount': 100,
        'remaining_amount': 164,
        'payment_status': 'partial',
      }));

      expect(series.paidAmount, 100);
      expect(series.remainingAmount, 164);
      expect(series.paymentStatus, 'partial');
    });

    test('an older payload with no payment fields falls back safely', () {
      // Confirms BookingSeries.fromJson never throws and never invents a
      // number — 0 paid, remaining computed from total, status "unpaid".
      final series = BookingSeries.fromJson(seriesJson(overrides: {
        'total_amount': 264,
      }));

      expect(series.paidAmount, 0);
      expect(series.remainingAmount, 264);
      expect(series.paymentStatus, 'unpaid');
    });

    test('remaining is derived only when the server omits it, and clamped '
        'at zero', () {
      final series = BookingSeries.fromJson(seriesJson(overrides: {
        'total_amount': 264,
        'paid_amount': 264,
        // remaining_amount omitted on purpose
      }));

      expect(series.remainingAmount, 0);
    });
  });
}
