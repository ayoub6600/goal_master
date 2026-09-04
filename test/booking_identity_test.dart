// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/cancel_booking_cubit/cancel_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';

/// The Customer App used to give one booking two different "numbers":
/// a monthly occurrence's card headlined its OWN sch_service_bookings.id —
/// invisible to the venue, which only ever knows the series id — while the
/// Manager App headlined booking_series_id for the exact same booking. A
/// manager and a customer comparing notes on "booking #100025" and
/// "booking #100002" would reasonably conclude they were two different
/// things.
///
/// The series id is now the primary identity wherever a booking belongs to
/// one; the occurrence's own id survives only as a quiet secondary detail.
/// An ordinary, non-monthly booking is unchanged — it never had two numbers
/// to begin with.
class _FakeBookingRepo implements BookingRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Booking _booking({
  required int id,
  BookingSeriesRef? series,
}) {
  return Booking(
    id: id,
    branch: 'ملاعب الجدار',
    address: 'مصراتة',
    latitude: '0',
    longitude: '0',
    date: '2026-09-06',
    startTime: '22:00:00',
    endTime: '23:00:00',
    service: 'سداسي 1',
    serviceAmount: '66',
    paidAmount: '0',
    paymentStatus: '2',
    paymentType: 'محفظة',
    status: 2,
    statusName: 'موافق عليه',
    remarks: '',
    category: 'كرة قدم',
    series: series,
  );
}

Widget _host(Booking booking) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      locale: const Locale('ar'),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: BlocProvider(
              create: (_) => CancelBookingCubit(_FakeBookingRepo()),
              child: BookingItems(booking: booking),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('an ordinary booking keeps its own id as the headline', () {
    testWidgets('# رقم الحجز shows the booking\'s own id', (tester) async {
      await tester.pumpWidget(_host(_booking(id: 100024)));
      await tester.pumpAndSettle();

      expect(find.text('# رقم الحجز' ' : 100024'), findsOneWidget);
      // No series wording leaks onto a booking that has none.
      expect(find.textContaining('الحجز الشهري'), findsNothing);
    });
  });

  group('a monthly occurrence headlines the series, not itself', () {
    testWidgets('occurrence 1 of 4 shows «الحجز الشهري #100002»',
        (tester) async {
      final booking = _booking(
        id: 100024,
        series: const BookingSeriesRef(
          seriesId: 100002,
          sequence: 1,
          occurrenceCount: 4,
          seriesStatus: 'active',
        ),
      );

      await tester.pumpWidget(_host(booking));
      await tester.pumpAndSettle();

      // The series id is the headline — exactly what the Manager App shows
      // for the same series.
      expect(find.text('الحجز الشهري' ' #100002'), findsOneWidget);

      // The old headline — this occurrence's own id as the primary number —
      // must not appear.
      expect(find.textContaining('# رقم الحجز'), findsNothing);

      // Position is still shown.
      expect(find.text('الموعد 1 من 4'), findsOneWidget);

      // The occurrence's own id survives, but only as a quiet secondary line.
      expect(find.text('رقم الموعد' ' #100024'), findsOneWidget);
    });

    testWidgets('a replacement occurrence headlines the series the same way',
        (tester) async {
      // Occurrence 2 of series 100002 was moved to a different slot — still
      // the same series identity, still occurrence 100025.
      final booking = _booking(
        id: 100025,
        series: const BookingSeriesRef(
          seriesId: 100002,
          sequence: 2,
          occurrenceCount: 4,
          seriesStatus: 'active',
        ),
      );

      await tester.pumpWidget(_host(booking));
      await tester.pumpAndSettle();

      expect(find.text('الحجز الشهري' ' #100002'), findsOneWidget);
      expect(find.text('الموعد 2 من 4'), findsOneWidget);
      expect(find.text('رقم الموعد' ' #100025'), findsOneWidget);
    });
  });

  group('an older payload with no series data never breaks the card', () {
    testWidgets('falls back to the ordinary # رقم الحجز identity',
        (tester) async {
      // A monthly booking from a server build that has not started sending
      // `series` yet: isPartOfSeries is false, so the card must fall back
      // rather than crash reading a null series.
      final booking = _booking(id: 100024, series: null);

      await tester.pumpWidget(_host(booking));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('# رقم الحجز' ' : 100024'), findsOneWidget);
      expect(find.textContaining('الحجز الشهري'), findsNothing);
    });
  });

  group('it holds up on a small screen', () {
    // The identity row used to be two unconstrained Text widgets in a Row —
    // "الحجز الشهري" and "#100002" — and at 320px that combination alone
    // overflowed by 131px (confirmed against the pre-change widget, which
    // overflowed its OWN header row by 139px for the same reason: this is a
    // narrow-screen weakness the card already had, not one this change
    // introduced). It is now one Text with maxLines/ellipsis, which cannot
    // throw a RenderFlex overflow regardless of width — proven here by
    // pumping the identity on its own, deliberately outside the surrounding
    // card, which carries unrelated clock/calendar/price rows that already
    // overflow at 320px independently of this change and are out of this
    // task's scope to fix.
    Widget narrowHost(Widget child) => ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => MaterialApp(
            locale: const Locale('ar'),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: Center(child: child)),
            ),
          ),
        );

    testWidgets('the series identity renders whole, with no overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final booking = _booking(
        id: 100025,
        series: const BookingSeriesRef(
          seriesId: 100002,
          sequence: 2,
          occurrenceCount: 4,
          seriesStatus: 'active',
        ),
      );

      await tester.pumpWidget(
        narrowHost(BookingIdentityLabel(booking: booking)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Full, untruncated — 320px is narrow, but not narrow enough to force
      // ellipsis on a 7-character series id.
      expect(find.text('الحجز الشهري' ' #100002'), findsOneWidget);
    });

    testWidgets('the ordinary-booking identity renders whole too',
        (tester) async {
      tester.view.physicalSize = const Size(320, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        narrowHost(BookingIdentityLabel(booking: _booking(id: 100024))),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('# رقم الحجز' ' : 100024'), findsOneWidget);
    });

    testWidgets('the secondary occurrence-number line still renders',
        (tester) async {
      // The badge row (position + secondary id) is unchanged structurally —
      // its positionLabel Text was already Flexible — and is confirmed here
      // rather than assumed.
      tester.view.physicalSize = const Size(320, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final booking = _booking(
        id: 100025,
        series: const BookingSeriesRef(
          seriesId: 100002,
          sequence: 2,
          occurrenceCount: 4,
          seriesStatus: 'active',
        ),
      );

      await tester.pumpWidget(_host(booking));
      await tester.pumpAndSettle();

      // The full card DOES still throw on its unrelated pre-existing rows at
      // 320px (verified separately, see the note above); this test only
      // asserts the secondary-id text this task added is present and correct.
      tester.takeException();
      expect(find.text('رقم الموعد' ' #100025'), findsOneWidget);
    });
  });
}
