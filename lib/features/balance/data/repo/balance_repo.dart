import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';

abstract class BalanceRepo {
  Future<Either<Failure, num>> getBalance();
}
