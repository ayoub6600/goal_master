import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/model/banner_model.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/data/model/service_model.dart';

abstract class AnalysisRepo {
  Future<Either<Failure, Analysis>> getAnalysis();
  Future<Either<Failure, ServiceResponse>> getService({
    double? lat,
    double? lng,
  });

  Future<Either<Failure, List<Slide>>> getBanner();

  Future<Either<Failure, BookingSlotsResponse>> filterBooking(
    String bookingStart,
    String bookingEnd,
    String branch,
    String startTime,
    String endTime,
    String categoryId,
    int page,
  );
}
