import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo.dart';

class BalanceRepoImp implements BalanceRepo {
  final ApiConsumer consumer;
  BalanceRepoImp(this.consumer);

  @override
  Future<Either<Failure, num>> getBalance() async {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.balance),
      (data) {
        // هنا نقوم بتحويل الرصيد إلى int
        final balance = data["data"]["balance"];
        return balance is num ? balance : 0;
      },
    );
  }

  @override
  Future<Either<Failure, String>> sendMoney(
      {required String amount, required String receiverId}) {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.sendMoney, data: {
        'amount': amount,
        'receiver_phone_number': receiverId,
      }),
      (data) {
        return data["message"];
      },
    );
  }

  Future<Either<Failure, PaginatedResponse<Transaction>>> transaction(
      int page) {
    return consumer.handleRequest(
      () => consumer.post(EndPoints.transaction(page)),
      (data) {
        return PaginatedResponse<Transaction>.fromJson(
          data["data"],
          (json) => Transaction.fromJson(json),
        );
      },
    );
  }
}
