import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'add_booking_state.dart';

class AddBookingCubit extends Cubit<AddBookingState> {
  AddBookingCubit(this.bookingRepo) : super(AddBookingInitial());
  final BookingRepo bookingRepo;
  Future<void> addBooking({
    required int employeeId,
    required int serviceId,
    required int zoneId,
    required int clubId,
    required String date,
    required String time,
  }) async {
    emit(AddBookingLoading());
    String fullname = SharedPreferenceUtil.getString(PrefKey.fullName);
    String phone = SharedPreferenceUtil.getString(PrefKey.phone);

    final result = await bookingRepo.addBooking(
      branchId: clubId,
      employeeId: employeeId,
      serviceId: serviceId,
      paymentType: 1,
      date: date,
      startTime: time,
      endTime: time,
      fullName: fullname,
      phone: phone,
      state: '1',
    );
    result.fold(
        (failure) => emit(AddBookingFailure(massage: failure.errMessage)),
        (data) => emit(AddBookingSuccess(massage: data)));
  }
}
