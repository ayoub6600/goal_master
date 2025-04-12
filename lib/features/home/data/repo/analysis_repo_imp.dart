import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
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
}
