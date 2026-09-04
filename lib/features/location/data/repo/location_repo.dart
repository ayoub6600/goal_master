import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';

/// Everything the app is allowed to ask about location.
///
/// Small on purpose. This is not address management — there is no editing and
/// no default-address concept — because every extra method here is another
/// place a second source of truth could start growing.
abstract class LocationRepo {
  /// The active location and the saved list, in one call.
  Future<Either<Failure, LocationBootstrap>> bootstrap();

  /// Turn a coordinate into the active location. The server resolves the zone.
  Future<Either<Failure, ActiveLocation>> setFromCoordinates({
    required double latitude,
    required double longitude,
    required String source,
    String? label,
    String? formattedAddress,
    String? city,
    bool save = false,
  });

  Future<Either<Failure, ActiveLocation>> activate(int id);

  Future<Either<Failure, ActiveLocation>> save(int id, String? label);

  Future<Either<Failure, Unit>> delete(int id);
}

/// The app's whole starting position, answered once.
///
/// Bundled because the app must choose between Home and the location screen
/// before it can draw anything, and two round trips to make one decision is a
/// visible flicker at best.
class LocationBootstrap {
  final ActiveLocation? active;
  final List<ActiveLocation> saved;
  final bool requiresLocation;

  const LocationBootstrap({
    required this.active,
    required this.saved,
    required this.requiresLocation,
  });
}
