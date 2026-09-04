import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/domain/monthly_grouping.dart';

/// The list is one row per session — a four-week series is four rows from the
/// server, unchanged. `isFirstOfItsSeries` is the entire rule that turns that
/// into one card: render the first row of a series' id, render nothing for
/// every row after it. These tests pin that rule directly, without pumping a
/// widget tree, because the rule is what a UI bug would actually violate.
void main() {
  Booking booking({required int id, BookingSeriesRef? series}) {
    return Booking(
      id: id,
      branch: 'ملاعب الجدار',
      address: 'مصراتة',
      latitude: '0',
      longitude: '0',
      date: '2026-09-06',
      startTime: '20:00:00',
      endTime: '21:00:00',
      service: 'سداسي 1',
      serviceAmount: '66',
      paidAmount: '0',
      paymentStatus: 'pending',
      paymentType: 'محفظة',
      status: 2,
      statusName: 'موافق عليه',
      remarks: '',
      category: 'كرة قدم',
      series: series,
    );
  }

  BookingSeriesRef ref(int seriesId, int sequence) => BookingSeriesRef(
        seriesId: seriesId,
        sequence: sequence,
        occurrenceCount: 4,
        seriesStatus: 'active',
      );

  test('a standalone booking is always first — nothing else can share it', () {
    final items = [booking(id: 100022, series: null)];

    expect(isFirstOfItsSeries(items, 0), isTrue);
  });

  test('four occurrences of one series: only the first renders', () {
    final items = [
      booking(id: 100024, series: ref(100002, 1)),
      booking(id: 100025, series: ref(100002, 2)),
      booking(id: 100026, series: ref(100002, 3)),
      booking(id: 100027, series: ref(100002, 4)),
    ];

    expect(isFirstOfItsSeries(items, 0), isTrue);
    expect(isFirstOfItsSeries(items, 1), isFalse);
    expect(isFirstOfItsSeries(items, 2), isFalse);
    expect(isFirstOfItsSeries(items, 3), isFalse);
  });

  test('two series interleaved with standalone bookings each collapse to one',
      () {
    final items = [
      booking(id: 100021, series: ref(100001, 4)), // series A, first seen
      booking(id: 100017, series: null), // standalone
      booking(id: 100020, series: ref(100001, 3)), // series A again
      booking(id: 100027, series: ref(100002, 4)), // series B, first seen
      booking(id: 100019, series: ref(100001, 2)), // series A again
      booking(id: 100026, series: ref(100002, 3)), // series B again
    ];

    expect(isFirstOfItsSeries(items, 0), isTrue); // series A
    expect(isFirstOfItsSeries(items, 1), isTrue); // standalone
    expect(isFirstOfItsSeries(items, 2), isFalse); // series A repeat
    expect(isFirstOfItsSeries(items, 3), isTrue); // series B
    expect(isFirstOfItsSeries(items, 4), isFalse); // series A repeat
    expect(isFirstOfItsSeries(items, 5), isFalse); // series B repeat
  });

  test('a cancelled occurrence still counts toward its series — it is not '
      'invisible, just not the representative unless it is first', () {
    final items = [
      booking(id: 100024, series: ref(100002, 1)),
      booking(id: 100025, series: ref(100002, 2)), // cancelled, still counted
    ];

    expect(isFirstOfItsSeries(items, 0), isTrue);
    expect(isFirstOfItsSeries(items, 1), isFalse);
  });
}
