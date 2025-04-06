part of 'booking_cubit.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

// class BookingSuccess extends BookingState {
//   final PagingController<int, Booking> pagingController;

//   BookingSuccess({
//     required this.pagingController,
//   });

//   @override
//   List<Object> get props => [pagingController];
// }
final class BookingSuccess extends BookingState {
  final PagingController<int, Booking> pagingController;

  const BookingSuccess({
    required this.pagingController,
  });
  @override
  List<Object> get props => [pagingController];
}

class BookingFailure extends BookingState {
  final String message;

  BookingFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
