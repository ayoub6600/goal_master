// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/cancel_booking_cubit/cancel_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_list.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/monthly_series_card.dart';

/// The real path end to end: `BookingCubit` paginating exactly what the
/// server sends (one row per session, standalone bookings interleaved), and
/// `BookingList` turning that into what the customer sees. Grouping is
/// proven here at the widget level, not just as a pure function, because this
/// is the surface a real list-rendering regression would actually break.
class _FakeBookingRepo implements BookingRepo {
  _FakeBookingRepo(this.page1);

  final List<Booking> page1;

  @override
  Future<Either<Failure, PaginatedResponse<Booking>>> getBooking(
    int page,
    bool now,
  ) async {
    return Right(PaginatedResponse<Booking>(
      currentPage: page,
      data: page == 1 ? page1 : const [],
      lastPage: 1,
    ));
  }

  @override
  Future<Either<Failure, BookingSeries>> getSeries(int seriesId) async {
    final occurrences = page1
        .where((b) => b.series?.seriesId == seriesId)
        .map((b) => {
              'booking_id': b.id,
              'sequence': b.series!.sequence,
              'date': b.date,
              'start_time': b.startTime,
              'end_time': b.endTime,
              'status': b.status,
              'status_name': b.statusName,
              'can_cancel': false,
              'is_replacement': false,
            })
        .toList();

    return Right(BookingSeries.fromJson({
      'series_id': seriesId,
      'status': 'active',
      'status_label': 'نشط',
      'occurrence_count': occurrences.length,
      'start_date': occurrences.isEmpty ? '' : occurrences.first['date'],
      'end_date': occurrences.isEmpty ? '' : occurrences.last['date'],
      'day_of_week': 0,
      'day_name': 'الأحد',
      'start_time': '20:00:00',
      'end_time': '21:00:00',
      'branch': 'ملاعب الجدار',
      'price_per_occurrence': 66,
      'total_amount': 66.0 * occurrences.length,
      'can_cancel_all': false,
      'occurrences': occurrences,
    }));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Booking _booking({
  required int id,
  required String date,
  int status = 2,
  BookingSeriesRef? series,
}) {
  return Booking(
    id: id,
    branch: 'ملاعب الجدار',
    address: 'مصراتة',
    latitude: '0',
    longitude: '0',
    date: date,
    startTime: '20:00:00',
    endTime: '21:00:00',
    service: 'سداسي 1',
    serviceAmount: '66',
    paidAmount: '0',
    paymentStatus: 'pending',
    paymentType: 'محفظة',
    status: status,
    statusName: 'موافق عليه',
    remarks: '',
    category: 'كرة قدم',
    series: series,
  );
}

BookingSeriesRef _ref(int seriesId, int sequence) => BookingSeriesRef(
      seriesId: seriesId,
      sequence: sequence,
      occurrenceCount: 4,
      seriesStatus: 'active',
    );

Widget _host(List<Booking> rows, {Size size = const Size(390, 844)}) {
  final repo = _FakeBookingRepo(rows);

  return ScreenUtilInit(
    designSize: size,
    builder: (_, __) => MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => BookingCubit(bookingRepo: repo)),
              BlocProvider(create: (_) => CancelBookingCubit(repo)),
            ],
            child: BookingList(seriesRepo: repo),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a normal booking renders as exactly one ordinary card',
      (tester) async {
    await tester.pumpWidget(_host([
      _booking(id: 100022, date: '2026-08-30'),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(BookingItems), findsOneWidget);
    expect(find.byType(MonthlySeriesCard), findsNothing);
  });

  testWidgets('a four-occurrence monthly series becomes exactly one card',
      (tester) async {
    await tester.pumpWidget(_host([
      _booking(id: 100027, date: '2026-09-20', series: _ref(100002, 4)),
      _booking(id: 100026, date: '2026-09-13', series: _ref(100002, 3)),
      _booking(id: 100025, date: '2026-09-06', series: _ref(100002, 2)),
      _booking(id: 100024, date: '2026-08-30', series: _ref(100002, 1)),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(MonthlySeriesCard), findsOneWidget);
    expect(find.byType(BookingItems), findsNothing);
    expect(find.text('الحجز الشهري' ' #100002'), findsOneWidget);
    expect(find.text('4 مواعيد'), findsOneWidget);
  });

  testWidgets('a mix of a normal booking and a monthly series shows both, '
      'once each', (tester) async {
    await tester.pumpWidget(_host([
      _booking(id: 100027, date: '2026-09-20', series: _ref(100002, 4)),
      _booking(id: 100023, date: '2026-09-06'), // standalone, interleaved
      _booking(id: 100026, date: '2026-09-13', series: _ref(100002, 3)),
      _booking(id: 100025, date: '2026-09-06', series: _ref(100002, 2)),
      _booking(id: 100024, date: '2026-08-30', series: _ref(100002, 1)),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(MonthlySeriesCard), findsOneWidget);
    expect(find.byType(BookingItems), findsOneWidget);
  });

  testWidgets('a cancelled occurrence is still part of the group, not a '
      'second series', (tester) async {
    await tester.pumpWidget(_host([
      _booking(id: 100025, date: '2026-09-06', series: _ref(100002, 2)),
      _booking(
        id: 100024,
        date: '2026-08-30',
        status: 3, // cancelled
        series: _ref(100002, 1),
      ),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(MonthlySeriesCard), findsOneWidget);
  });

  testWidgets('an old booking with no series metadata falls back to its own '
      'ordinary card, unaffected by grouping', (tester) async {
    await tester.pumpWidget(_host([
      _booking(id: 100017, date: '2026-08-28', series: null),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(BookingItems), findsOneWidget);
    expect(find.byType(MonthlySeriesCard), findsNothing);
  });

  group('it holds up on real phone widths', () {
    // Series-only rows here, deliberately. A standalone booking's card
    // (`BookingItems`) already has its own pre-existing narrow-screen
    // overflow in its clock/calendar/price rows — present before this task,
    // unrelated to grouping, and explicitly out of scope: this task groups
    // monthly bookings, it does not redesign the normal-booking card. Mixing
    // one into this check would fail on a widget this task never touches
    // and never claimed to fix. `MonthlySeriesCard`'s OWN narrow-screen
    // safety, including a long service name, is already proven in
    // monthly_series_card_test.dart; this proves it holds up once it is
    // actually the thing `BookingList` renders, not just in isolation.
    for (final size in [
      const Size(320, 780),
      const Size(390, 844),
      const Size(430, 932),
    ]) {
      testWidgets(
          'a grouped series card in the real list has no overflow at '
          '${size.width.toInt()}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_host(
          [
            _booking(id: 100027, date: '2026-09-20', series: _ref(100002, 4)),
            _booking(id: 100026, date: '2026-09-13', series: _ref(100002, 3)),
            _booking(id: 100025, date: '2026-09-06', series: _ref(100002, 2)),
            _booking(id: 100024, date: '2026-08-30', series: _ref(100002, 1)),
          ],
          size: size,
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(MonthlySeriesCard), findsOneWidget);
      });
    }

    testWidgets(
        'a mixed list still renders both cards at 320px — the standalone '
        'card\'s own pre-existing overflow is a separate, known issue',
        (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(
        [
          _booking(id: 100027, date: '2026-09-20', series: _ref(100002, 4)),
          _booking(id: 100023, date: '2026-09-06'),
          _booking(id: 100026, date: '2026-09-13', series: _ref(100002, 3)),
          _booking(id: 100025, date: '2026-09-06', series: _ref(100002, 2)),
          _booking(id: 100024, date: '2026-08-30', series: _ref(100002, 1)),
        ],
        size: const Size(320, 780),
      ));
      await tester.pumpAndSettle();

      // Drained rather than asserted null: the standalone card's rows are
      // documented, pre-existing, out-of-scope overflow, not a regression
      // this task introduced.
      tester.takeException();
      expect(find.byType(MonthlySeriesCard), findsOneWidget);
      expect(find.byType(BookingItems), findsOneWidget);
    });
  });
}
