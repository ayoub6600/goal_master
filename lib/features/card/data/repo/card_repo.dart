import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/card/data/model/topup_checkout.dart';

abstract class CardRepo {
  Future<Either<Failure, String>> addCard(
    String code,
  );
  //Transactionstore

  /// The server opens a card top-up for [amount] and signs its checkout.
  Future<Either<Failure, TopUpCheckout>> startTopUp(String amount);

  /// The Lightbox finished: the server asks the bank, then credits.
  Future<Either<Failure, TopUpConfirmation>> confirmTopUp(String reference);
}
