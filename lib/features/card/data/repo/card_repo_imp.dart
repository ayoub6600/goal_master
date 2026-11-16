import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/card/data/model/topup_checkout.dart';
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
  Future<Either<Failure, TopUpCheckout>> startTopUp(String amount) {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.startTopUp, data: {'amount': amount}),
      (res) => TopUpCheckout.fromJson(Map<String, dynamic>.from(res['data'] as Map)),
    );
  }

  @override
  Future<Either<Failure, TopUpConfirmation>> confirmTopUp(String reference) {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.transactionStore, data: {'reference': reference}),
      (res) => TopUpConfirmation.fromJson(Map<String, dynamic>.from(res as Map)),
    );
  }
}
