part of 'add_transaction_cubit.dart';

sealed class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object> get props => [];
}

final class AddTransactionInitial extends AddTransactionState {}

final class AddTransactionLoading extends AddTransactionState {}

final class AddTransactionSuccess extends AddTransactionState {
  final String message;
  const AddTransactionSuccess(this.message);
}

final class AddTransactionError extends AddTransactionState {
  final String message;
  const AddTransactionError(this.message);
}
