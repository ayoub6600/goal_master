import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/card/data/repo/card_repo.dart';

class CardRepoImp implements CardRepo {
  final ApiConsumer consumer;
  CardRepoImp(this.consumer);

  @override
  Future<Either<Failure, String>> addCard(String code) {
    return consumer.handleRequest(
      () => consumer.post(
        EndPoints.charge,
        data: {
          'code': code,
        },
      ),
      (p0) {
        String message = p0['message'];
        return message;
      },
    );
  }

  @override
  Future<Either<Failure, String>> addTransaction(String amount, String status) {
    return consumer.handleRequest(
      () => consumer.post(
        EndPoints.transactionStore,
        data: {
          'amount': amount,
          'status': status,
        },
      ),
      (p0) {
        String message = p0['message'];
        return message;
      },
    );
  }
}
