import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
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
        return balance is num
            ? balance
            : 0; // إذا كانت القيمة غير صحيحة، نرجع 0
      },
    );
  }
}
