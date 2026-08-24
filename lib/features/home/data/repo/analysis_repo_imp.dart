import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
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

  /// Same last-known GPS position LayoutCubit already persists — reused so
  /// zone-scoped sliders (see Slide::zone_id on the backend) only show to
  /// customers currently resolved into that zone.
  Map<String, dynamic> get _locationParams {
    final hasLat = SharedPreferenceUtil.haveKey(PrefKey.savedLat) == true;
    final hasLng = SharedPreferenceUtil.haveKey(PrefKey.savedLng) == true;
    if (!hasLat || !hasLng) return const {};
    return {
      'lat': SharedPreferenceUtil.getDouble(PrefKey.savedLat),
      'lng': SharedPreferenceUtil.getDouble(PrefKey.savedLng),
    };
  }

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

  @override
  Future<Either<Failure, ServiceResponse>> getService({
    double? lat,
    double? lng,
  }) {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.getServices, data: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
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
