import 'package:bloc/bloc.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

import 'booking_details_state.dart';

class BookingDetailsCubit extends Cubit<BookingDetailsState> {
  final BookingRepo bookingRepo;
  final int id;

  BookingDetailsCubit(this.bookingRepo, this.id)
      : super(BookingDetailsInitial());

  Future<void> getBookingInfo() async {
    emit(BookingDetailsLoading());
    final result = await bookingRepo.getBookingInfo(id);
    result.fold((failure) => emit(BookingDetailsError(failure.errMessage)),
        (bookingDetails) {
      emit(BookingDetailsSuccess(bookingDetails));
    });
  }
}
