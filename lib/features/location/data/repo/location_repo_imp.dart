import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/location/data/model/active_location.dart';
import 'package:goal_master/features/location/data/repo/location_repo.dart';

class LocationRepoImp extends LocationRepo {
  final ApiConsumer apiConsumer;

  LocationRepoImp(this.apiConsumer);

  @override
  Future<Either<Failure, LocationBootstrap>> bootstrap() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.locationBootstrap),
      (data) {
        final payload = Map<String, dynamic>.from(data['data'] as Map);

        return LocationBootstrap(
          active: ActiveLocation.maybeFrom(payload['active_location']),
          saved: ((payload['saved_locations'] as List?) ?? const [])
              .map(ActiveLocation.maybeFrom)
              .whereType<ActiveLocation>()
              .toList(growable: false),
          requiresLocation: payload['requires_location'] == true,
        );
      },
    );
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
  }) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(EndPoints.locationSet, data: {
        'latitude': latitude,
        'longitude': longitude,
        'source': source,
        if (label != null) 'label': label,
        if (formattedAddress != null) 'formatted_address': formattedAddress,
        if (city != null) 'city': city,
        'save': save,
      }),
      // A non-serviceable point still comes back as a location. The caller
      // decides what to say about it — throwing here would turn "we are not in
      // your area yet" into an error the customer cannot act on.
      (data) => ActiveLocation.maybeFrom(data['data'])!,
    );
  }

  @override
  Future<Either<Failure, ActiveLocation>> activate(int id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(EndPoints.locationActivate, data: {'id': id}),
      (data) => ActiveLocation.maybeFrom(data['data'])!,
    );
  }

  @override
  Future<Either<Failure, ActiveLocation>> save(int id, String? label) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(EndPoints.locationSave, data: {
        'id': id,
        if (label != null) 'label': label,
      }),
      (data) => ActiveLocation.maybeFrom(data['data'])!,
    );
  }

  @override
  Future<Either<Failure, Unit>> delete(int id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(EndPoints.locationDelete, data: {'id': id}),
      (_) => unit,
    );
  }
}
