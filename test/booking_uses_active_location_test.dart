// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/category_model.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/monthly_booking_cubit/monthly_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/service_cubit/service_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/booking_details.dart';
import 'package:goal_master/features/coins/data/repo/coins_repo.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';
import 'package:goal_master/features/location/data/repo/location_repo.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/location/presentation/view/required_location_view.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A booking backend that records the one call these tests are about.
///
/// noSuchMethod covers the rest of the interface: twenty other methods would
/// be twenty pieces of scaffolding hiding the single assertion that matters —
/// which zone the club list was fetched for.
class _FakeBookingRepo implements BookingRepo {
  final List<int> listClubCalls = [];

  @override
  Future<Either<Failure, List<ClubResponce>>> listClub(int zoneId) async {
    listClubCalls.add(zoneId);
    return right(const <ClubResponce>[]);
  }

  /// Needed by the initialBranch path, which loads the branch's categories.
  @override
  Future<Either<Failure, List<CategoryModel>>> listCategory({
    required int branchId,
  }) async =>
      right(const <CategoryModel>[]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocationRepo implements LocationRepo {
  _FakeLocationRepo(this.active);

  ActiveLocation? active;

  @override
  Future<Either<Failure, LocationBootstrap>> bootstrap() async => right(
        LocationBootstrap(
          active: active,
          saved: const [],
          requiresLocation: active == null,
        ),
      );

  @override
  Future<Either<Failure, ActiveLocation>> setFromCoordinates({
    required double latitude,
    required double longitude,
    required String source,
    String? label,
    String? formattedAddress,
    String? city,
    bool save = false,
  }) async {
    active = ActiveLocation(
      id: 1,
      latitude: latitude,
      longitude: longitude,
      zoneId: 10,
      zoneName: 'زون أ',
      source: source,
    );
    return right(active!);
  }

  @override
  Future<Either<Failure, ActiveLocation>> activate(int id) async => right(active!);

  @override
  Future<Either<Failure, ActiveLocation>> save(int id, String? label) async =>
      right(active!);

  @override
  Future<Either<Failure, Unit>> delete(int id) async => right(unit);
}

ActiveLocation _zoneA() => const ActiveLocation(
      id: 1,
      latitude: 32.0,
      longitude: 13.0,
      zoneId: 10,
      zoneName: 'زون أ',
      source: 'map',
    );

ActiveLocation _zoneB() => const ActiveLocation(
      id: 2,
      latitude: 32.3,
      longitude: 15.0,
      zoneId: 20,
      zoneName: 'زون ب',
      source: 'map',
    );

void main() {
  late _FakeBookingRepo bookingRepo;
  late ActiveLocationCubit locationCubit;
  late PageViewCubit pageViewCubit;
  late ClubCubit clubCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // main() does this before runApp; the cubit's cache write relies on it.
    await SharedPreferenceUtil.getInstance();
    bookingRepo = _FakeBookingRepo();
    pageViewCubit = PageViewCubit();
    clubCubit = ClubCubit(bookingRepo);
  });

  /// The booking screen with the same cubits the real route provides.
  Future<void> pumpBooking(
    WidgetTester tester, {
    required ActiveLocation? location,
    Map<String, dynamic>? initialBranch,
  }) async {
    locationCubit = ActiveLocationCubit(_FakeLocationRepo(location));
    if (location != null) await locationCubit.bootstrap(userId: 1);

    // BookingDetails sits inside PageWrapper, whose back button reads
    // GoRouter from context — so the harness needs a real router, not just a
    // MaterialApp. Mounting the screen for real is the point: these tests are
    // about what the actual widget does on entry.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: locationCubit),
              BlocProvider.value(value: pageViewCubit),
              BlocProvider.value(value: clubCubit),
              BlocProvider(create: (_) => CategoryCubit(bookingRepo)),
              BlocProvider(create: (_) => ServiceCubit(bookingRepo)),
              BlocProvider(create: (_) => EmployeeCubit(bookingRepo)),
              BlocProvider(create: (_) => AddBookingCubit(bookingRepo)),
              BlocProvider(create: (_) => MonthlyBookingCubit(bookingRepo)),
              BlocProvider(create: (_) => CreateMonthlyBookingCubit(bookingRepo)),
              BlocProvider(create: (_) => CalendarCubit(bookingRepo)),
              BlocProvider(create: (_) => CoinsCubit(_FakeCoinsRepo())),
            ],
            child: BookingDetails(initialBranch: initialBranch),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      // The booking screen sizes itself with ScreenUtil, exactly as the app
      // does. Without this the widgets throw before any assertion is reached.
      ScreenUtilInit(
        designSize: const Size(390, 844),
        child: MaterialApp.router(
          locale: const Locale('ar'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  group('احجز الآن with an Active Location', () {
    testWidgets('20. «اختر المنطقة» is not part of the flow', (tester) async {
      await pumpBooking(tester, location: _zoneA());
      await tester.pump();

      // Gone, not hidden. The customer chose a location on Home; asking them
      // to choose a region again was the duplicate system this removes.
      expect(find.text('اختر المنطقة'), findsNothing);
      expect(find.text('اختر المنطقة المناسبة للحجز الذي تريده'), findsNothing);
    });

    testWidgets('21. the zone is preloaded into the booking state',
        (tester) async {
      await pumpBooking(tester, location: _zoneA());
      await tester.pump();

      // Both, not just the id: later steps read the name, and a club list
      // fetched for a zone the state does not know about is how a booking
      // ends up attached to the wrong place.
      expect(pageViewCubit.state.zoneId, 10);
      expect(pageViewCubit.state.zoneTitle, 'زون أ');
    });

    testWidgets('22. the club list is fetched for the active zone',
        (tester) async {
      await pumpBooking(tester, location: _zoneA());
      await tester.pump();

      expect(bookingRepo.listClubCalls, [10]);
    });

    testWidgets('23. a different active zone books in that zone',
        (tester) async {
      await pumpBooking(tester, location: _zoneB());
      await tester.pump();

      expect(bookingRepo.listClubCalls, [20]);
      expect(pageViewCubit.state.zoneId, 20);
      // Zone A's venues can never appear: nothing ever asked for them.
      expect(bookingRepo.listClubCalls, isNot(contains(10)));
    });

    testWidgets('24. the wizard opens on the club step', (tester) async {
      await pumpBooking(tester, location: _zoneA());
      await tester.pump();

      // Not "page 1 with page 0 skipped" — the zone page no longer exists, so
      // the first step IS the club list.
      expect(pageViewCubit.state.currentPage, PageViewCubit.club);
    });
  });

  group('احجز الآن without an Active Location', () {
    testWidgets('25. the centralized selector opens, not the old zone step',
        (tester) async {
      await pumpBooking(tester, location: null);
      await tester.pumpAndSettle();

      // The fallback is the ONE location chooser the whole app uses. Falling
      // back to the old zone page would have kept both systems alive, which
      // is the thing being removed.
      expect(find.byKey(const Key('required_location_title')), findsOneWidget);
      expect(find.text('اختر المنطقة'), findsNothing);
    });

    testWidgets('26. no club list is requested without a zone', (tester) async {
      await pumpBooking(tester, location: null);
      await tester.pumpAndSettle();

      // Never an un-scoped fetch. "All clubs everywhere" is the fallback this
      // whole change exists to prevent.
      expect(bookingRepo.listClubCalls, isEmpty);
      expect(pageViewCubit.state.zoneId, isNull);
    });

    testWidgets('27. choosing a location resumes the booking automatically',
        (tester) async {
      await pumpBooking(tester, location: null);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('required_location_title')), findsOneWidget);

      // The customer picks a place, and the selector closes itself — exactly
      // what RequiredLocationView.onResolved does. They must NOT have to go
      // back to Home and press احجز الآن again; the intent they already
      // expressed carries on by itself.
      await locationCubit.setFromCoordinates(
        latitude: 32.0, longitude: 13.0, source: 'map',
      );
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.byType(RequiredLocationView))).pop();
      await tester.pumpAndSettle();

      expect(pageViewCubit.state.zoneId, 10);
      expect(bookingRepo.listClubCalls, [10]);
    });
  });

  group('booking a venue directly', () {
    testWidgets('28. initialBranch still jumps past the club step',
        (tester) async {
      await pumpBooking(
        tester,
        location: _zoneA(),
        initialBranch: {
          'branchId': 77,
          'branchName': 'ملاعب الجدار',
          'zoneId': 20,
          'zoneName': 'زون ب',
          'allowLocalPayment': true,
        },
      );
      await tester.pump();

      expect(pageViewCubit.state.clubId, 77);
      expect(pageViewCubit.state.currentPage, PageViewCubit.category);
    });

    testWidgets(
        '29. a venue outside the discovery zone is still bookable',
        (tester) async {
      // Shopping from Zone A, opening a Zone B venue's card.
      await pumpBooking(
        tester,
        location: _zoneA(),
        initialBranch: {
          'branchId': 77,
          'branchName': 'ملاعب الجدار',
          'zoneId': 20,
          'zoneName': 'زون ب',
          'allowLocalPayment': true,
        },
      );
      await tester.pump();

      // The VENUE's zone wins, not the discovery zone. Active Location scopes
      // what a customer is shown; it must never invalidate one they picked on
      // purpose.
      expect(pageViewCubit.state.zoneId, 20);
      expect(pageViewCubit.state.zoneTitle, 'زون ب');
      expect(pageViewCubit.state.clubId, 77);

      // And no club list is fetched at all — the branch is already known.
      expect(bookingRepo.listClubCalls, isEmpty);
    });
  });
}

/// Only present so the checkout step can be constructed; never exercised here.
class _FakeCoinsRepo implements CoinsRepo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
