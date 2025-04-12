import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';

abstract class AnalysisRepo {
  Future<Either<Failure, Analysis>> getAnalysis();
}
