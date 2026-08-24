import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/coins/data/model/coin_model.dart';

abstract class CoinsRepo {
  Future<Either<Failure, CoinBalance>> getBalance();
  Future<Either<Failure, CoinHistoryPage>> getHistory({int page = 1});
  Future<Either<Failure, Map<String, dynamic>>> redeem(int coins);
}
