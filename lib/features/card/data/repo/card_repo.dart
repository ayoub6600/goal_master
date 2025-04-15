import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';

abstract class CardRepo {
  Future<Either<Failure, String>> addCard(
    String code,
  );
}
