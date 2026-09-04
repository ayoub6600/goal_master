// dartz exports a `State` that collides with Flutter's.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/attendance/data/mandatory_action.dart';
import 'package:goal_master/features/attendance/data/mandatory_action_repo.dart';
import 'package:goal_master/features/attendance/presentation/mandatory_action_gate.dart';
import 'package:goal_master/features/location/data/active_location_snapshot.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';
import 'package:goal_master/features/location/data/repo/location_repo.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/location/presentation/required_location_gate.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A stand-in backend whose answers the test controls.
///
/// Counts calls, because several of these tests are about what the app does
/// NOT do — re-reading GPS on the way back from Account, or asking for a
/// location it already has.
class _FakeLocationRepo implements LocationRepo {
  _FakeLocationRepo({this.active, List<ActiveLocation>? saved, this.fail = false})
      : saved = saved ?? const [];

  ActiveLocation? active;
  List<ActiveLocation> saved;
  bool fail;

  int bootstrapCalls = 0;
  final List<Map<String, dynamic>> setCalls = [];
  final List<int> activateCalls = [];

  @override
  Future<Either<Failure, LocationBootstrap>> bootstrap() async {
    bootstrapCalls++;
    if (fail) return left(Failure(errMessage: 'offline'));

    return right(LocationBootstrap(
      active: active,
      saved: saved,
      requiresLocation: active == null,
    ));
  }

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
    setCalls.add({'lat': latitude, 'lng': longitude, 'source': source});
    if (fail) return left(Failure(errMessage: 'offline'));

    // The SERVER resolves the zone. The fake mirrors that: a point inside the
    // test's serviceable box gets a zone, one outside gets none.
    final serviceable = latitude > 0 && longitude > 0;

    active = ActiveLocation(
      id: 1,
      latitude: latitude,
      longitude: longitude,
      zoneId: serviceable ? 10 : null,
      zoneName: serviceable ? 'زون أ' : null,
      source: source,
      label: label,
      isSaved: save,
    );

    return right(active!);
  }

  @override
  Future<Either<Failure, ActiveLocation>> activate(int id) async {
    activateCalls.add(id);
    if (fail) return left(Failure(errMessage: 'offline'));

    final match = saved.firstWhere((l) => l.id == id);
    active = match;
    return right(match);
  }

  @override
  Future<Either<Failure, ActiveLocation>> save(int id, String? label) async =>
      right(active!);

  @override
  Future<Either<Failure, Unit>> delete(int id) async {
    saved = saved.where((l) => l.id != id).toList();
    if (active?.id == id) active = null;
    return right(unit);
  }
}

ActiveLocation _location({
  int id = 1,
  int? zoneId = 10,
  String? zoneName = 'زون أ',
  double lat = 32.0,
  double lng = 13.0,
  String? label,
}) {
  return ActiveLocation(
    id: id,
    latitude: lat,
    longitude: lng,
    zoneId: zoneId,
    zoneName: zoneName,
    source: 'map',
    label: label,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await primePreferences();
    ActiveLocationSnapshot.clear();
  });

  // ---------- the model ----------

  group('ActiveLocation', () {
    test('1. a coordinate without a zone is not serviceable', () {
      // Not an error, and emphatically not "everywhere" — the distinction the
      // whole feature rests on.
      expect(_location(zoneId: null, zoneName: null).isServiceable, isFalse);
      expect(_location().isServiceable, isTrue);
    });

    test('2. it shows the most specific name it actually has', () {
      expect(_location(label: 'بيتي').displayName, 'بيتي');
      expect(_location().displayName, 'زون أ');
      expect(
        _location(zoneId: null, zoneName: null).displayName,
        contains('32.0000'),
      );
    });

    test('3. it survives a round trip through JSON', () {
      final original = _location(label: 'بيتي');
      final restored = ActiveLocation.maybeFrom(original.toJson());

      expect(restored, original);
      expect(restored!.zoneId, 10);
      expect(restored.label, 'بيتي');
    });
  });

  // ---------- the cubit ----------

  group('ActiveLocationCubit', () {
    test('4. no location on the account means the selector is required', () async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(active: null));

      await cubit.bootstrap(userId: 1);

      expect(cubit.state.status, ActiveLocationStatus.missing);
      expect(cubit.state.hasUsableLocation, isFalse);
    });

    test('5. an existing location makes the app ready', () async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(active: _location()));

      await cubit.bootstrap(userId: 1);

      expect(cubit.state.status, ActiveLocationStatus.ready);
      expect(cubit.state.zoneId, 10);
    });

    test('6. a resolved coordinate is persisted and published', () async {
      final repo = _FakeLocationRepo(active: null);
      final cubit = ActiveLocationCubit(repo);
      await cubit.bootstrap(userId: 1);

      final ok = await cubit.setFromCoordinates(
        latitude: 32.0, longitude: 13.0, source: 'current_location',
      );

      expect(ok, isTrue);
      expect(repo.setCalls.single['source'], 'current_location');
      expect(cubit.state.zoneId, 10);
      // Repositories have no BuildContext; this is how they see it.
      expect(ActiveLocationSnapshot.current?.zoneId, 10);
    });

    test('7. an unsupported coordinate does not let the customer through', () async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(active: null));
      await cubit.bootstrap(userId: 1);

      final ok = await cubit.setFromCoordinates(
        latitude: -5.0, longitude: -5.0, source: 'map',
      );

      expect(ok, isFalse);
      expect(cubit.state.status, ActiveLocationStatus.unserviceable);
      // Never widened to every city. Showing pitches nobody can reach is
      // worse than showing none.
      expect(cubit.state.zoneId, isNull);
      expect(cubit.state.hasUsableLocation, isFalse);
    });

    test('8. selecting a saved location makes it active', () async {
      final saved = [
        _location(id: 1, zoneName: 'زون أ', label: 'بيتي'),
        _location(id: 2, zoneId: 20, zoneName: 'زون ب', label: 'الشغل'),
      ];
      final repo = _FakeLocationRepo(active: saved.first, saved: saved);
      final cubit = ActiveLocationCubit(repo);
      await cubit.bootstrap(userId: 1);

      final ok = await cubit.selectSaved(2);

      expect(ok, isTrue);
      expect(repo.activateCalls, [2]);
      expect(cubit.state.zoneId, 20);
    });

    test('9. a restart restores the location from the account', () async {
      final repo = _FakeLocationRepo(active: _location(zoneId: 20, zoneName: 'زون ب'));

      // A brand-new cubit, as after a cold start.
      final cubit = ActiveLocationCubit(repo);
      await cubit.bootstrap(userId: 1);

      expect(cubit.state.zoneId, 20);
      expect(cubit.state.status, ActiveLocationStatus.ready);
    });

    test('10. offline, the cache keeps the customer working', () async {
      final repo = _FakeLocationRepo(active: _location());
      final warm = ActiveLocationCubit(repo);
      await warm.bootstrap(userId: 1);

      // Same device, same account, no network.
      repo.fail = true;
      final cold = ActiveLocationCubit(repo);
      await cold.bootstrap(userId: 1);

      // The cache paints; it never becomes the truth. The customer is not
      // sent to a location screen they already answered.
      expect(cold.state.status, ActiveLocationStatus.ready);
      expect(cold.state.zoneId, 10);
    });

    test('11. the cache is never read across accounts', () async {
      final repoA = _FakeLocationRepo(active: _location(zoneId: 20, zoneName: 'زون ب'));
      final a = ActiveLocationCubit(repoA);
      await a.bootstrap(userId: 1);
      expect(a.state.zoneId, 20);

      // Customer B signs in on the same handset with no location of their own.
      // A's cached city must not appear, even for a frame.
      final repoB = _FakeLocationRepo(active: null);
      final b = ActiveLocationCubit(repoB);
      await b.bootstrap(userId: 2);

      expect(b.state.status, ActiveLocationStatus.missing);
      expect(b.state.location, isNull);
    });

    test('12. signing out clears the device, not the account', () async {
      final repo = _FakeLocationRepo(active: _location());
      final cubit = ActiveLocationCubit(repo);
      await cubit.bootstrap(userId: 1);

      cubit.clearForSignOut();

      expect(cubit.state.location, isNull);
      // The projection repositories read is emptied too — otherwise the next
      // customer's first requests carry the previous one's coordinates.
      expect(ActiveLocationSnapshot.current, isNull);
      // The server copy is untouched: it is what restores their city on
      // signing back in.
      expect(repo.active, isNotNull);
    });

    test('13. the legacy savedLat/savedLng pair is adopted once', () async {
      // Written through the real API rather than as mock initial values:
      // SharedPreferences caches its instance, so values injected after the
      // first getInstance() never reach it and the test would pass vacuously.
      await SharedPreferenceUtil.putDouble(PrefKey.savedLat, 32.5);
      await SharedPreferenceUtil.putDouble(PrefKey.savedLng, 13.5);
      await SharedPreferenceUtil.putBool(PrefKey.legacyLocationMigrated, false);

      final repo = _FakeLocationRepo(active: null);
      final cubit = ActiveLocationCubit(repo);
      await cubit.bootstrap(userId: 1);

      // A customer updating the app is not asked a question they already
      // answered — their last position is carried into the account.
      expect(repo.setCalls, hasLength(1));
      expect(repo.setCalls.single['lat'], 32.5);

      // And only once. Someone who deliberately clears their location is not
      // dragged back to it next launch.
      final again = ActiveLocationCubit(repo);
      repo.active = null;
      await again.bootstrap(userId: 1);
      expect(repo.setCalls, hasLength(1));
    });
  });

  // ---------- the snapshot repositories read ----------

  group('ActiveLocationSnapshot', () {
    test('14. no location means no location parameters', () {
      ActiveLocationSnapshot.clear();

      // Explicitly un-scoped, rather than a guess at coordinates.
      expect(ActiveLocationSnapshot.requestParams, isEmpty);
    });

    test('15. it carries coordinates and the resolved zone together', () {
      ActiveLocationSnapshot.publish(_location());

      expect(ActiveLocationSnapshot.requestParams, {
        'lat': 32.0,
        'lng': 13.0,
        'zone_id': 10,
      });
    });

    test('16. an unserviceable point sends no zone', () {
      ActiveLocationSnapshot.publish(_location(zoneId: null, zoneName: null));

      final params = ActiveLocationSnapshot.requestParams;
      expect(params.containsKey('zone_id'), isFalse);
      expect(params['lat'], 32.0);
    });
  });

  // ---------- the gate ----------

  group('RequiredLocationGate', () {
    Widget wrap(ActiveLocationCubit cubit, {bool loggedIn = true}) {
      return MaterialApp(
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: cubit,
          child: RequiredLocationGate(
            isLoggedIn: () => loggedIn,
            child: const Scaffold(body: Text('HOME')),
          ),
        ),
      );
    }

    testWidgets('17. no location opens the selector', (tester) async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(active: null));

      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('required_location_title')), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
    });

    testWidgets('18. an existing location goes straight to the app', (tester) async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(active: _location()));

      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(find.byKey(const Key('required_location_title')), findsNothing);
    });

    testWidgets('19. a signed-out customer is never blocked', (tester) async {
      final repo = _FakeLocationRepo(active: null);
      final cubit = ActiveLocationCubit(repo);

      await tester.pumpWidget(wrap(cubit, loggedIn: false));
      await tester.pumpAndSettle();

      // Location belongs to an account. Blocking the login screen on one
      // would be a door locked from the inside.
      expect(find.text('HOME'), findsOneWidget);
      expect(repo.bootstrapCalls, 0);
    });

    testWidgets('20. an unserviceable location is explained, not hidden', (tester) async {
      final cubit = ActiveLocationCubit(
        _FakeLocationRepo(active: _location(zoneId: null, zoneName: null)),
      );

      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('unserviceable_notice')), findsOneWidget);
    });

    testWidgets('21. the saved option is hidden when nothing is saved', (tester) async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(active: null));

      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      // An option that opens an empty list is a dead end dressed as a choice,
      // and a first-time customer meets it before they can have saved anything.
      expect(find.byKey(const Key('option_saved')), findsNothing);
      expect(find.byKey(const Key('option_current_location')), findsOneWidget);
      expect(find.byKey(const Key('option_map')), findsOneWidget);
    });

    testWidgets('22. the saved option appears once something is saved', (tester) async {
      final cubit = ActiveLocationCubit(_FakeLocationRepo(
        active: null,
        saved: [_location(id: 3, label: 'بيتي')],
      ));

      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('option_saved')), findsOneWidget);
    });

    testWidgets('23. a rebuild does not re-read the account', (tester) async {
      final repo = _FakeLocationRepo(active: _location());
      final cubit = ActiveLocationCubit(repo);

      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      final callsAfterFirstBuild = repo.bootstrapCalls;

      // Rebuilding the tree is not a reason to ask again — and must never be
      // a reason to ask for GPS again.
      await tester.pumpWidget(wrap(cubit));
      await tester.pumpAndSettle();

      expect(repo.bootstrapCalls, callsAfterFirstBuild);
      expect(cubit.state.zoneId, 10);
    });
  });

  // ---------- the original bug ----------

  group('Home → Account → Home', () {
    testWidgets(
        '24. the active location is identical after leaving and returning',
        (tester) async {
      final repo = _FakeLocationRepo(active: _location(zoneId: 20, zoneName: 'زون ب'));
      final cubit = ActiveLocationCubit(repo);

      // A cubit provided ABOVE the router, which is the fix: it is not rebuilt
      // by navigation, so it cannot lose the answer.
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: RequiredLocationGate(
            isLoggedIn: () => true,
            child: const _FakeTabs(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(cubit.state.zoneId, 20);
      final before = cubit.state.location;

      // Home → Account.
      await tester.tap(find.text('ACCOUNT_TAB'));
      await tester.pumpAndSettle();

      // Account → Home. The Home tab's own cubits are rebuilt here; the
      // location must not be.
      await tester.tap(find.text('HOME_TAB'));
      await tester.pumpAndSettle();

      expect(cubit.state.location, before);
      expect(cubit.state.zoneId, 20, reason: 'Zone B must still be active');
      // And crucially: no fresh GPS request and no re-selection. The persisted
      // choice is the authority.
      expect(repo.setCalls, isEmpty);
      expect(repo.activateCalls, isEmpty);

      // Which is what the booking flow will read a moment later.
      expect(ActiveLocationSnapshot.requestParams['zone_id'], 20);
    });
  });

  // ---------- gate ordering ----------

  group('gate ordering', () {
    testWidgets(
        '25. a pending attendance question is asked before the location one',
        (tester) async {
      final repo = _FakeLocationRepo(active: null);
      final locationCubit = ActiveLocationCubit(repo);

      // Both gates have something to say. The attendance question is an
      // obligation the customer already owes us, so it wins — otherwise a
      // customer could dodge it forever by never choosing a location.
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: locationCubit,
          child: MandatoryActionGate(
            isLoggedIn: () => true,
            repo: _FakeMandatoryRepo(pending_: const [
              MandatoryAction(
                id: 1,
                bookingId: 9,
                title: 'هل حضرت؟',
                message: 'أكد حضورك للحجز',
              ),
            ]),
            child: RequiredLocationGate(
              isLoggedIn: () => true,
              child: const Scaffold(body: Text('HOME')),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('هل حضرت؟'), findsOneWidget);

      // The attendance prompt is an opaque, full-surface overlay with
      // canPop: false, so the location screen renders BENEATH it rather than
      // being replaced. What matters is that it cannot be reached: tapping
      // where its options sit does nothing, so location onboarding is not a
      // way around a question the customer already owes an answer to.
      await tester.tap(
        find.byKey(const Key('option_current_location')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(repo.setCalls, isEmpty);
      expect(find.text('هل حضرت؟'), findsOneWidget);
    });

    testWidgets(
        '26. with attendance settled, the location question is asked next',
        (tester) async {
      final locationCubit = ActiveLocationCubit(_FakeLocationRepo(active: null));

      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: locationCubit,
          child: MandatoryActionGate(
            isLoggedIn: () => true,
            repo: _FakeMandatoryRepo(pending_: const []),
            child: RequiredLocationGate(
              isLoggedIn: () => true,
              child: const Scaffold(body: Text('HOME')),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('required_location_title')), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
    });
  });
}

/// Just enough attendance backend to prove which gate wins.
class _FakeMandatoryRepo implements MandatoryActionRepo {
  _FakeMandatoryRepo({required this.pending_});

  final List<MandatoryAction> pending_;

  @override
  Future<Either<Failure, List<MandatoryAction>>> pending() async =>
      right(pending_);

  @override
  Future<Either<Failure, List<MandatoryAction>>> answer({
    required int confirmationId,
    required bool attended,
  }) async =>
      right(const []);
}

/// A two-tab shell that rebuilds its body on every switch.
///
/// Deliberately destroys and recreates the "Home" subtree, because that is
/// exactly what the real layout does — and what used to wipe the location.
class _FakeTabs extends StatefulWidget {
  const _FakeTabs();

  @override
  State<_FakeTabs> createState() => _FakeTabsState();
}

class _FakeTabsState extends State<_FakeTabs> {
  bool _home = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_home)
            const Expanded(child: Center(child: Text('HOME_CONTENT')))
          else
            const Expanded(child: Center(child: Text('ACCOUNT_CONTENT'))),
          TextButton(
            onPressed: () => setState(() => _home = true),
            child: const Text('HOME_TAB'),
          ),
          TextButton(
            onPressed: () => setState(() => _home = false),
            child: const Text('ACCOUNT_TAB'),
          ),
        ],
      ),
    );
  }
}

/// SharedPreferenceUtil is a lazy singleton; this primes it for the fakes.
Future<void> primePreferences() async {
  await SharedPreferenceUtil.getInstance();
}
