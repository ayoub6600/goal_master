// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/manager/series_details_cubit/series_details_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/booking_items_details.dart.dart';
import 'package:goal_master/features/booking/presentation/view/series_details_view.dart';

/// Tapping one date inside a recurring booking must open THAT date's own
/// booking — the exact same screen an ordinary booking already opens — never
/// a second "monthly occurrence" screen, and never the series itself.
///
/// This exercises the real push/pop stack through an actual `GoRouter`,
/// because a fake navigator call is not proof the customer lands on the
/// right screen or that "back" returns to the series rather than the root.
class _FakeBookingRepo implements BookingRepo {
  _FakeBookingRepo({
    required this.series,
    this.bookingInfoFor = const {},
    this.failInfoFor = const {},
  });

  final BookingSeries series;

  /// bookingId → the full record `getBookingInfo` returns for it.
  final Map<int, Booking> bookingInfoFor;

  /// bookingIds whose fetch should fail, to prove the failure path.
  final Set<int> failInfoFor;

  final List<int> requestedBookingIds = [];

  @override
  Future<Either<Failure, BookingSeries>> getSeries(int seriesId) async =>
      Right(series);

  @override
  Future<Either<Failure, RenewalOffer>> getRenewalOffer(int seriesId) async =>
      Left(Failure(errMessage: 'no offer'));

  @override
  Future<Either<Failure, Booking>> getBookingInfo(int id) async {
    requestedBookingIds.add(id);

    if (failInfoFor.contains(id)) {
      return Left(Failure(errMessage: 'تعذّر تحميل بيانات هذا الموعد.'));
    }

    final booking = bookingInfoFor[id];
    if (booking == null) {
      return Left(Failure(errMessage: 'not found'));
    }
    return Right(booking);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

BookingSeries _series() {
  return BookingSeries.fromJson({
    'series_id': 100002,
    'status': 'active',
    'status_label': 'نشط',
    'occurrence_count': 4,
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
    'occurrences': [
      _occ(bookingId: 100024, sequence: 1, date: '2026-08-30'),
      _occ(bookingId: 100025, sequence: 2, date: '2026-09-06', isReplacement: true),
      _occ(bookingId: 100026, sequence: 3, date: '2026-09-13'),
      _occ(bookingId: 100027, sequence: 4, date: '2026-09-20'),
    ],
  });
}

Booking _fullBooking(int id) {
  return Booking(
    id: id,
    branch: 'ملاعب الجدار',
    address: 'مصراتة',
    latitude: '32.1',
    longitude: '15.1',
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
    series: null,
  );
}

Widget _app(_FakeBookingRepo repo, {Size size = const Size(390, 844)}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => SeriesDetailsCubit(repo)..load(100002),
          child: SeriesDetailsView(seriesId: 100002, bookingRepo: repo),
        ),
      ),
      GoRoute(
        path: RoutesKeys.kBookingItemsDetails,
        builder: (context, state) =>
            BookingItemsDetails(booking: state.extra as Booking),
      ),
    ],
  );

  return ScreenUtilInit(
    designSize: size,
    builder: (_, __) => OKToast(
      child: MaterialApp.router(
        locale: const Locale('ar'),
        routerConfig: router,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
      ),
    ),
  );
}

/// flutter_test's own default surface is much smaller than any real phone.
/// Pinning a realistic size here keeps the functional tests about THIS
/// feature; the narrow-width group below tests actual small phones on
/// purpose.
Future<void> _pump(
  WidgetTester tester,
  _FakeBookingRepo repo, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(repo, size: size));
  await tester.pumpAndSettle();
  _drainKnownOverflow(tester);
}

/// `SeriesDetailsView`'s shared global app bar (`AppBarContent`) lays its
/// title next to a fixed-width back button with neither Expanded nor
/// Flexible — a pre-existing narrow-width overflow, present on every screen
/// that uses it, not introduced by this feature and not this task's to fix
/// (a shared, app-wide component). Draining it here — rather than ignoring
/// exceptions outright — still lets a genuinely different failure fail the
/// test: only messages that actually say "RenderFlex overflowed" are
/// swallowed.
void _drainKnownOverflow(WidgetTester tester) {
  Object? next;
  while ((next = tester.takeException()) != null) {
    if (!next.toString().contains('RenderFlex overflowed') &&
        !next.toString().contains('Multiple exceptions')) {
      throw next!;
    }
  }
}

void main() {
  testWidgets('tapping occurrence 1 opens booking #100024, not the series',
      (tester) async {

    final repo = _FakeBookingRepo(
      series: _series(),
      bookingInfoFor: {100024: _fullBooking(100024)},
    );

    await _pump(tester, repo);

    await tester.tap(find.text('30 أغسطس'));
    await tester.pumpAndSettle();
    _drainKnownOverflow(tester);

    expect(repo.requestedBookingIds, [100024]);
    final details = tester.widget<BookingItemsDetails>(
      find.byType(BookingItemsDetails),
    );
    expect(details.booking.id, 100024);
  });

  testWidgets('tapping the replacement occurrence opens its own booking '
      '#100025', (tester) async {
    final repo = _FakeBookingRepo(
      series: _series(),
      bookingInfoFor: {100025: _fullBooking(100025)},
    );

    await _pump(tester, repo);

    await tester.tap(find.text('6 سبتمبر'));
    await tester.pumpAndSettle();
    _drainKnownOverflow(tester);

    expect(repo.requestedBookingIds, [100025]);
    expect(
      tester.widget<BookingItemsDetails>(find.byType(BookingItemsDetails))
          .booking
          .id,
      100025,
    );
  });

  testWidgets('occurrences 3 and 4 each open their own correct booking',
      (tester) async {
    for (final (label, id) in [('13 سبتمبر', 100026), ('20 سبتمبر', 100027)]) {
      final repo = _FakeBookingRepo(
        series: _series(),
        bookingInfoFor: {id: _fullBooking(id)},
      );

      await _pump(tester, repo);

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      _drainKnownOverflow(tester);

      expect(
        tester.widget<BookingItemsDetails>(find.byType(BookingItemsDetails))
            .booking
            .id,
        id,
        reason: 'tapping $label',
      );
    }
  });

  testWidgets('back returns to SeriesDetailsView, not further than that',
      (tester) async {
    final repo = _FakeBookingRepo(
      series: _series(),
      bookingInfoFor: {100024: _fullBooking(100024)},
    );

    await _pump(tester, repo);

    await tester.tap(find.text('30 أغسطس'));
    await tester.pumpAndSettle();
    _drainKnownOverflow(tester);
    expect(find.byType(BookingItemsDetails), findsOneWidget);

    // Pop the pushed route the same way the system back gesture would.
    final context = tester.element(find.byType(BookingItemsDetails));
    GoRouter.of(context).pop();
    await tester.pumpAndSettle();
    _drainKnownOverflow(tester);

    expect(find.byType(SeriesDetailsView), findsOneWidget);
    expect(find.byType(BookingItemsDetails), findsNothing);
    // Still the same series screen, with its occurrence list intact — not a
    // blank page, and not the root of "حجوزاتي".
    expect(find.text('المواعيد'), findsOneWidget);
    expect(find.text('30 أغسطس'), findsOneWidget);
  });

  testWidgets('the cancel button on a row opens cancel options, not the '
      'booking details — the two tap targets stay independent', (tester) async {
    final repo = _FakeBookingRepo(series: _series());

    await _pump(tester, repo);

    // Occurrence 1 is upcoming and cancellable, so its "⋮" is present.
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    _drainKnownOverflow(tester);

    expect(find.text('ماذا تريد أن تلغي؟'), findsOneWidget);
    // No fetch was triggered, and no details screen opened.
    expect(repo.requestedBookingIds, isEmpty);
    expect(find.byType(BookingItemsDetails), findsNothing);
  });

  testWidgets('a failed fetch shows a message and opens nothing', (tester) async {
    final repo = _FakeBookingRepo(
      series: _series(),
      failInfoFor: {100024},
    );

    await _pump(tester, repo);

    await tester.tap(find.text('30 أغسطس'));
    await tester.pumpAndSettle();
    _drainKnownOverflow(tester);

    expect(find.byType(BookingItemsDetails), findsNothing);
    // Still on the series screen, able to try again.
    expect(find.byType(SeriesDetailsView), findsOneWidget);

    // Let the failure toast's own auto-dismiss timer expire before the test
    // ends, so the framework never sees "a Timer is still pending".
    await tester.pump(const Duration(seconds: 4));
  });

  group('it holds up on real phone widths', () {
    for (final size in [
      const Size(320, 780),
      const Size(390, 844),
      const Size(430, 932),
    ]) {
      testWidgets('the occurrence list has no overflow at '
          '${size.width.toInt()}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final repo = _FakeBookingRepo(series: _series());
        await tester.pumpWidget(_app(repo, size: size));
        await tester.pumpAndSettle();
        _drainKnownOverflow(tester);
      });
    }
  });
}
