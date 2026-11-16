part of 'add_transaction_cubit.dart';

sealed class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object> get props => [];
}

final class AddTransactionInitial extends AddTransactionState {}

final class AddTransactionLoading extends AddTransactionState {}

/// The server opened the top-up; the Lightbox can be shown.
final class AddTransactionReady extends AddTransactionState {
  final TopUpCheckout checkout;
  const AddTransactionReady(this.checkout);
}

final class AddTransactionSuccess extends AddTransactionState {
  final String message;
  const AddTransactionSuccess(this.message);
}

/// Paid, not yet confirmed by the bank. The server credits it on its own.
final class AddTransactionPending extends AddTransactionState {
  final String message;
  const AddTransactionPending(this.message);
}

final class AddTransactionError extends AddTransactionState {
  final String message;
  const AddTransactionError(this.message);
}
