part of 'cancel_booking_cubit.dart';

sealed class CancelBookingState extends Equatable {
  const CancelBookingState();

  @override
  List<Object> get props => [];
}

final class CancelBookingInitial extends CancelBookingState {}

final class CancelBookingLoading extends CancelBookingState {}

final class CancelBookingSuccess extends CancelBookingState {
  final String message;

  const CancelBookingSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

final class CancelBookingFailure extends CancelBookingState {
  final String message;

  const CancelBookingFailure({required this.message});
  @override
  List<Object> get props => [message];
}
