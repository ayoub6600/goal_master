import 'package:dartz/dartz.dart';
import 'package:goal_master/core/components/paginated_response.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';

abstract class BalanceRepo {
  Future<Either<Failure, num>> getBalance();
  Future<Either<Failure, String>> sendMoney({
    required String amount,
    required String receiverId,
  });

  Future<Either<Failure, PaginatedResponse<Transaction>>> transaction(int page);
}
