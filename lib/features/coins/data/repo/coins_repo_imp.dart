import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/coins/data/model/coin_model.dart';
import 'package:goal_master/features/coins/data/repo/coins_repo.dart';

class CoinsRepoImp extends CoinsRepo {
  final ApiConsumer apiConsumer;

  CoinsRepoImp(this.apiConsumer);

  @override
  Future<Either<Failure, CoinBalance>> getBalance() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.coinsBalance),
      (data) => CoinBalance.fromJson(data),
    );
  }

  @override
  Future<Either<Failure, CoinHistoryPage>> getHistory({int page = 1}) {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.coinsHistory(page)),
      (data) => CoinHistoryPage.fromJson(data),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> redeem(int coins) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(
        EndPoints.coinsRedeem,
        isFormData: false,
        data: {'coins': coins},
      ),
      (data) => Map<String, dynamic>.from(data['data'] ?? {}),
    );
  }
}
