import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo.dart';

class AnalysisRepoImp extends AnalysisRepo {
  final ApiConsumer consumer;
  AnalysisRepoImp(this.consumer);
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
}
// var data = FormData.fromMap({
//   'branch': '12',
//   'start_time': '20:00:00',
//   'end_time': '22:00:00',
//   'booking_start': '2025-03-25',
//   'booking_end': '2025-04-28',
//   'category_id': '26'
// });
