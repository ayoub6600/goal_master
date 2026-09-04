import 'package:dartz/dartz.dart';
import 'package:goal_master/features/location/data/active_location_snapshot.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/model/banner_model.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/data/model/service_model.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';

class AnalysisRepoImp extends AnalysisRepo {
  final ApiConsumer consumer;
  AnalysisRepoImp(this.consumer);

  /// The customer's Active Location — the one the whole marketplace uses.
  ///
  /// Previously read straight from savedLat/savedLng, which meant Home had its
  /// own idea of where the customer was and could disagree with the booking
  /// flow two taps later. It now reads the same resolved location as every
  /// other surface, zone included.
  Map<String, dynamic> get _locationParams =>
      ActiveLocationSnapshot.requestParams;

  @override
  Future<Either<Failure, Analysis>> getAnalysis() {
    return consumer.handleRequest(
      () => consumer.get(EndPoints.analysis),
      (data) => Analysis.fromJson(data["data"]),
    );
  }

  @override
  Future<Either<Failure, BookingSlotsResponse>> filterBooking(
    String bookingStart,
    String bookingEnd,
    String branch,
    String startTime,
    String endTime,
    String categoryId,
    int page,
  ) {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.fillterNewBooking(page), data: {
        if (branch?.isNotEmpty ?? false) 'branch': branch,
        if (startTime?.isNotEmpty ?? false) 'start_time': startTime,
        if (endTime?.isNotEmpty ?? false) 'end_time': endTime,
        'booking_start': bookingStart,
        'booking_end': bookingEnd,
        if (categoryId?.isNotEmpty ?? false) 'category_id': categoryId,
      }),
      (data) => BookingSlotsResponse.fromJson(data),
    );
  }

  @override
  Future<Either<Failure, List<Slide>>> getBanner() {
    return consumer.handleRequest(
      () => consumer.get(EndPoints.banner, queryParameters: _locationParams),
      (data) => SlideData.fromJson({'data': data["data"]}).data,
    );
  }

  /// The venues Home shows, scoped to where the customer is shopping.
  ///
  /// THIS IS THE ORIGINAL BUG. Home's cubit is created inside the Home tab's
  /// BlocProvider, so leaving for Account and coming back destroyed it and
  /// called getServicesInfo() again with no coordinates at all — and an
  /// un-scoped request returns every city. The customer had chosen a zone
  /// seconds earlier; the app simply forgot on the way back.
  ///
  /// Explicit coordinates still win, for the caller that has just moved the
  /// map. Everything else falls back to the Active Location, which is account-
  /// owned and cannot be lost to navigation.
  @override
  Future<Either<Failure, ServiceResponse>> getService({
    double? lat,
    double? lng,
  }) {
    final fallback = ActiveLocationSnapshot.requestParams;

    final latitude = lat ?? fallback['lat'];
    final longitude = lng ?? fallback['lng'];

    return consumer.handleRequest(
      () => consumer.post(EndPoints.getServices, data: {
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
      }),
      (data) => ServiceResponse.fromJson(data),
    );
  }
}
//getServicesInfo
// var data = FormData.fromMap({
//   'branch': '12',
//   'start_time': '20:00:00',
//   'end_time': '22:00:00',
//   'booking_start': '2025-03-25',
//   'booking_end': '2025-04-28',
//   'category_id': '26'
// });
