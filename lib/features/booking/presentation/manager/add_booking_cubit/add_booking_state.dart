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

  /// What the customer spent on this booking, so the success screen can say
  /// so. The coins *earned* aren't known here — the backend only awards them
  /// once the booking completes, and the app reads that from its balance.
  final int coinsRedeemed;

  const AddBookingSuccess({required this.massage, this.coinsRedeemed = 0});

  @override
  List<Object> get props => [massage, coinsRedeemed];
}

final class AddBookingFailure extends AddBookingState {
  final String massage;

  const AddBookingFailure({required this.massage});

  @override
  List<Object> get props => [massage];
}
