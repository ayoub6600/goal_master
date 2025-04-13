part of 'add_booking_cubit.dart';

sealed class AddBookingState extends Equatable {
  const AddBookingState();

  @override
  List<Object> get props => [];
}

final class AddBookingInitial extends AddBookingState {}

final class AddBookingLoading extends AddBookingState {}

final class AddBookingSuccess extends AddBookingState {
  final String massage;

  const AddBookingSuccess({required this.massage});

  @override
  List<Object> get props => [massage];
}

final class AddBookingFailure extends AddBookingState {
  final String massage;

  const AddBookingFailure({required this.massage});

  @override
  List<Object> get props => [massage];
}
