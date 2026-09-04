import 'package:goal_master/features/location/data/model/active_location.dart';

/// The current Active Location, readable without a BuildContext.
///
/// Repositories are plain classes — they cannot read a cubit. Before this they
/// each reached into SharedPreferences for savedLat/savedLng, which is how the
/// app ended up with several independent ideas of where the customer was.
///
/// This is NOT a second source of truth. It is a read-only projection of
/// ActiveLocationCubit's state, written by exactly one line in that cubit and
/// by nothing else. Nothing here decides anything, nothing persists, and
/// nothing survives a restart — the account does that. If the cubit has not
/// resolved yet, this is null and callers send no location rather than
/// inventing one.
class ActiveLocationSnapshot {
  ActiveLocationSnapshot._();

  static ActiveLocation? _current;

  static ActiveLocation? get current => _current;

  /// Called only by ActiveLocationCubit. Anything else calling this is a bug.
  static void publish(ActiveLocation? location) => _current = location;

  static void clear() => _current = null;

  /// The lat/lng every location-aware request carries.
  ///
  /// Empty when there is no location — an explicitly un-scoped request the
  /// server can recognise, rather than a guess at coordinates.
  static Map<String, dynamic> get requestParams {
    final location = _current;
    if (location == null) return const {};

    return {
      'lat': location.latitude,
      'lng': location.longitude,
      // Sent alongside so the server never has to re-resolve what it already
      // resolved. The coordinates stay for anything that needs real distance.
      if (location.isServiceable) 'zone_id': location.zoneId,
    };
  }
}
