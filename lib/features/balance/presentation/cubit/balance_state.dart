part of 'balance_cubit.dart';

sealed class BalanceState extends Equatable {
  const BalanceState();

  @override
  List<Object> get props => [];
}

final class BalanceInitial extends BalanceState {}

final class BalanceLoading extends BalanceState {}

final class BalanceLoaded extends BalanceState {
  final num balance;
  const BalanceLoaded(this.balance);
}

final class BalanceError extends BalanceState {
  final String errMessage;
  const BalanceError(this.errMessage);
}
