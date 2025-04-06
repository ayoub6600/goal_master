import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'cancel_booking_state.dart';

class CancelBookingCubit extends Cubit<CancelBookingState> {
  CancelBookingCubit(this.bookingRepo) : super(CancelBookingInitial());
  final BookingRepo bookingRepo;

  Future<void> cancelBooking(int id) async {
    emit(CancelBookingLoading());
    final result = await bookingRepo.cancelBooking(id);
    result.fold(
      (failure) => emit(CancelBookingFailure(message: failure.errMessage)),
      (booking) => emit(CancelBookingSuccess(message: "تم الغاء الحجز")),
    );
  }
}
