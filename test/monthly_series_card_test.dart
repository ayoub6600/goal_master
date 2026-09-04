// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/monthly_series_card.dart';

/// A booking backend that returns one fixed `getSeries` result. Everything
/// else falls to `noSuchMethod` — this card only ever calls that one method.
class _FakeBookingRepo implements BookingRepo {
  _FakeBookingRepo(this.result);

  final Either<Failure, BookingSeries> result;

  @override
  Future<Either<Failure, BookingSeries>> getSeries(int seriesId) async =>
      result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Booking _representative({int id = 100024, String service = 'سداسي 1'}) {
  return Booking(
    id: id,
    branch: 'ملاعب الجدار',
    address: 'مصراتة',
    latitude: '0',
    longitude: '0',
    date: '2026-08-30',
    startTime: '20:00:00',
    endTime: '21:00:00',
    service: service,
    serviceAmount: '66',
    paidAmount: '0',
    paymentStatus: 'pending',
    paymentType: 'محفظة',
    status: 2,
    statusName: 'موافق عليه',
    remarks: '',
    category: 'كرة قدم',
    series: const BookingSeriesRef(
      seriesId: 100002,
      sequence: 1,
      occurrenceCount: 4,
      seriesStatus: 'active',
    ),
  );
}

Map<String, dynamic> _occ({
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

BookingSeries _series({
  List<Map<String, dynamic>> occurrences = const [],
  Map<String, dynamic> overrides = const {},
}) {
  return BookingSeries.fromJson({
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
  });
}

Widget _host(Widget child, {Size size = const Size(390, 844)}) {
  return ScreenUtilInit(
    designSize: size,
    builder: (_, __) => MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

void main() {
  group('the card represents the series, not the first occurrence blindly',
      () {
    testWidgets('shows the series identity, service, branch and dates',
        (tester) async {
      final series = _series(occurrences: [
        _occ(bookingId: 100024, sequence: 1, date: '2026-08-30'),
        _occ(bookingId: 100025, sequence: 2, date: '2026-09-06'),
        _occ(bookingId: 100026, sequence: 3, date: '2026-09-13'),
        _occ(bookingId: 100027, sequence: 4, date: '2026-09-20'),
      ]);

      await tester.pumpWidget(_host(MonthlySeriesCard(
        seriesId: 100002,
        representative: _representative(),
        bookingRepo: _FakeBookingRepo(Right(series)),
      )));
      await tester.pumpAndSettle();

      expect(find.text('الحجز الشهري' ' #100002'), findsOneWidget);
      expect(find.text('سداسي 1'), findsOneWidget);
      expect(find.text('4 مواعيد'), findsOneWidget);
      expect(find.text('نشط'), findsOneWidget);
    });

    testWidgets('the next occurrence is the deterministic one, not row 0',
        (tester) async {
      final series = _series(occurrences: [
        _occ(bookingId: 100024, sequence: 1, date: '2026-08-30'), // past
        _occ(bookingId: 100025, sequence: 2, date: '2026-09-06'), // next
        _occ(bookingId: 100026, sequence: 3, date: '2026-09-13'),
        _occ(bookingId: 100027, sequence: 4, date: '2026-09-20'),
      ]);

      await tester.pumpWidget(_host(MonthlySeriesCard(
        seriesId: 100002,
        representative: _representative(),
        bookingRepo: _FakeBookingRepo(Right(series)),
      )));
      await tester.pumpAndSettle();

      expect(find.text('الموعد القادم'), findsOneWidget);
      // Not the finished-series message.
      expect(find.text('اكتملت كل مواعيد هذا الحجز الشهري'), findsNothing);
    });

    testWidgets('a replacement next occurrence carries its badge',
        (tester) async {
      final series = _series(occurrences: [
        _occ(bookingId: 100024, sequence: 1, date: '2026-08-30'),
        _occ(
          bookingId: 100025,
          sequence: 2,
          date: '2026-09-06',
          isReplacement: true,
        ),
      ]);

      await tester.pumpWidget(_host(MonthlySeriesCard(
        seriesId: 100002,
        representative: _representative(),
        bookingRepo: _FakeBookingRepo(Right(series)),
      )));
      await tester.pumpAndSettle();

      expect(find.text('موعد بديل'), findsOneWidget);
    });

    testWidgets('a fully played/cancelled series shows the finished state, '
        'not a stale next-date', (tester) async {
      final series = _series(occurrences: [
        _occ(bookingId: 1, sequence: 1, date: '2026-08-01', status: 4),
        _occ(bookingId: 2, sequence: 2, date: '2026-08-08', status: 3),
      ]);

      await tester.pumpWidget(_host(MonthlySeriesCard(
        seriesId: 100002,
        representative: _representative(),
        bookingRepo: _FakeBookingRepo(Right(series)),
      )));
      await tester.pumpAndSettle();

      expect(find.text('اكتملت كل مواعيد هذا الحجز الشهري'), findsOneWidget);
      expect(find.text('الموعد القادم'), findsNothing);
    });

    testWidgets('the payment status reads the server field, not a client sum',
        (tester) async {
      final series = _series(
        occurrences: [_occ(bookingId: 1, sequence: 1, date: '2026-09-06')],
        overrides: {
          'paid_amount': 66,
          'remaining_amount': 198,
          'payment_status': 'partial',
        },
      );

      await tester.pumpWidget(_host(MonthlySeriesCard(
        seriesId: 100002,
        representative: _representative(),
        bookingRepo: _FakeBookingRepo(Right(series)),
      )));
      await tester.pumpAndSettle();

      expect(find.text('مدفوع جزئيًا'), findsOneWidget);
    });
  });

  group('a failed or missing series fetch degrades safely', () {
    testWidgets('falls back to the ordinary individual booking card',
        (tester) async {
      await tester.pumpWidget(_host(MonthlySeriesCard(
        seriesId: 100002,
        representative: _representative(id: 100024),
        bookingRepo:
            _FakeBookingRepo(Left(Failure(errMessage: 'network error'))),
      )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The individual card, exactly as it rendered before this feature —
      // including its OWN "الحجز الشهري #100002" headline, since that
      // unification is BookingItems' own behaviour and correct here too.
      // What must NOT appear is anything from the group card itself, which
      // never got the chance to render.
      expect(find.byType(BookingItems), findsOneWidget);
      expect(find.textContaining('مواعيد'), findsNothing);
      expect(find.text('الموعد القادم'), findsNothing);
    });
  });

  group('it holds up on real phone widths', () {
    for (final size in [
      const Size(320, 780),
      const Size(390, 844),
      const Size(430, 932),
    ]) {
      testWidgets('no overflow at ${size.width.toInt()}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final series = _series(occurrences: [
          _occ(bookingId: 100024, sequence: 1, date: '2026-08-30'),
          _occ(
            bookingId: 100025,
            sequence: 2,
            date: '2026-09-06',
            isReplacement: true,
          ),
          _occ(bookingId: 100026, sequence: 3, date: '2026-09-13'),
          _occ(bookingId: 100027, sequence: 4, date: '2026-09-20'),
        ]);

        await tester.pumpWidget(_host(
          MonthlySeriesCard(
            seriesId: 100002,
            representative: _representative(
              service: 'ملعب سداسي كبير بإضاءة كاملة وتكييف',
            ),
            bookingRepo: _FakeBookingRepo(Right(series)),
          ),
          size: size,
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
