part of 'transaction_cubit.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final PagingController<int, Transaction> pagingController;

  const TransactionSuccess({required this.pagingController});

  @override
  List<Object?> get props => [pagingController];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
