import 'package:equatable/equatable.dart';

import '../../../data/model/booking_history_response.dart';

abstract class BookingDetailsState extends Equatable {
  const BookingDetailsState();

  @override
  List<Object?> get props => [];
}

class BookingDetailsInitial extends BookingDetailsState {}

class BookingDetailsLoading extends BookingDetailsState {}

class BookingDetailsSuccess extends BookingDetailsState {
  final Booking bookingDetails;

  const BookingDetailsSuccess(this.bookingDetails);

  @override
  List<Object?> get props => [bookingDetails];
}

class BookingDetailsError extends BookingDetailsState {
  final String message;

  const BookingDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
