import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/location/presentation/view/required_location_view.dart';

/// Holds the app until the customer has said where they are shopping from.
///
/// Sits INSIDE MandatoryActionGate, deliberately. The attendance question is a
/// commercial obligation the customer already owes us; asking "where are you?"
/// first would let somebody dodge it by never choosing a location. So the
/// order is:
///
///   authentication → mandatory attendance → required location → the app
///
/// The two gates cannot deadlock: the location endpoints are not behind the
/// attendance middleware, and the attendance gate needs no location at all, so
/// whichever is showing can always be answered.
///
/// Signed-out customers pass straight through. Location is owned by the
/// account, so there is nobody to own one yet, and blocking the login screen
/// on a location would be a door locked from the inside.
class RequiredLocationGate extends StatefulWidget {
  const RequiredLocationGate({
    super.key,
    required this.child,
    this.isLoggedIn,
  });

  final Widget child;

  /// Injected in tests; read from preferences in the app.
  final bool Function()? isLoggedIn;

  @override
  State<RequiredLocationGate> createState() => _RequiredLocationGateState();
}

class _RequiredLocationGateState extends State<RequiredLocationGate>
    with WidgetsBindingObserver {
  int? _bootstrappedFor;

  bool get _loggedIn =>
      widget.isLoggedIn?.call() ??
      (SharedPreferenceUtil.getString(PrefKey.login) == 'true');

  int get _userId => SharedPreferenceUtil.getInt(PrefKey.userId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeBootstrap());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back to the foreground re-reads the account, which is how a
    // location changed on another device arrives here. It does NOT re-read
    // GPS: the customer chose a place, and quietly moving them because their
    // phone moved is the opposite of a chosen location.
    if (state == AppLifecycleState.resumed) {
      _maybeBootstrap();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Catches the sign-in that happens after this gate is already mounted, and
    // the account switch that happens on the same device.
    _maybeBootstrap();
  }

  void _maybeBootstrap() {
    if (!mounted || !_loggedIn) return;

    final userId = _userId;

    // Keyed to the account, not to a "have I run yet" flag. When customer B
    // signs in after customer A, the id changes and the location is read again
    // from B's account — which is what stops B inheriting A's city.
    if (_bootstrappedFor == userId) return;
    _bootstrappedFor = userId;

    context.read<ActiveLocationCubit>().bootstrap(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loggedIn) return widget.child;

    return BlocBuilder<ActiveLocationCubit, ActiveLocationState>(
      builder: (context, state) {
        switch (state.status) {
          case ActiveLocationStatus.missing:
          case ActiveLocationStatus.unserviceable:
            // Its OWN Navigator, deliberately.
            //
            // This gate is mounted from MaterialApp.router's builder, which
            // sits ABOVE the router's Navigator — so a Navigator.push from the
            // screen below crashed with "context does not include a
            // Navigator", killing both «موقعي الحالي» and «تحديد على الخريطة».
            // Giving the blocking screen a Navigator of its own is the honest
            // fix: it can push the map, and because that Navigator contains
            // nothing else, there is still no way to navigate around the gate.
            return Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => const RequiredLocationView(isBlocking: true),
              ),
            );

          case ActiveLocationStatus.initial:
          case ActiveLocationStatus.loading:
            // The app underneath keeps rendering while the account is read.
            // Flashing a location screen at a customer who has one, every
            // launch, would be worse than a moment of stale content.
            return widget.child;

          case ActiveLocationStatus.failed:
          case ActiveLocationStatus.ready:
            // A failure with no cache is not a reason to demand a location the
            // customer has already given — that is a network problem, and the
            // app says so elsewhere.
            return widget.child;
        }
      },
    );
  }
}
