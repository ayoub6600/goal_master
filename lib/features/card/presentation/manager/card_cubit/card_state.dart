part of 'card_cubit.dart';

sealed class CardState extends Equatable {
  const CardState();

  @override
  List<Object> get props => [];
}

final class CardInitial extends CardState {}

final class CardLoading extends CardState {}

final class CardSuccess extends CardState {
  final String cards;
  const CardSuccess(this.cards);
}

final class CardFailure extends CardState {
  final String message;
  const CardFailure(this.message);
}
