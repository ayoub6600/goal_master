import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'add_booking_state.dart';

class AddBookingCubit extends Cubit<AddBookingState> {
  AddBookingCubit(this.bookingRepo) : super(AddBookingInitial());
  final BookingRepo bookingRepo;
  int _paymentType = 1; // default is cash
  void setPaymentType(int value) {
    _paymentType = value;
  }

  Future<void> addBooking({
    required int employeeId,
    required int serviceId,
    required int zoneId,
    required int clubId,
    required String date,
    required String time,
  }) async {
    emit(AddBookingLoading());
    if (!_validateBookingData(
      employeeId: employeeId,
      serviceId: serviceId,
      zoneId: zoneId,
      clubId: clubId,
      date: date,
      time: time,
    )) return;
    String fullname = SharedPreferenceUtil.getString(PrefKey.fullName);
    String phone = SharedPreferenceUtil.getString(PrefKey.phone);

    final result = await bookingRepo.addBooking(
      branchId: clubId,
      employeeId: employeeId,
      serviceId: serviceId,
      paymentType: _paymentType,
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

  bool _validateBookingData({
    required int employeeId,
    required int serviceId,
    required int zoneId,
    required int clubId,
    required String date,
    required String time,
  }) {
    if (employeeId == 0 || serviceId == 0 || zoneId == 0 || clubId == 0) {
      emit(
          const AddBookingFailure(massage: "يرجى اختيار جميع الحقول المطلوبة"));
      return false;
    }

    if (date.isEmpty || time.isEmpty) {
      emit(const AddBookingFailure(massage: "يرجى اختيار التاريخ والوقت"));
      return false;
    }

    if (_paymentType != 1 && _paymentType != 4) {
      emit(const AddBookingFailure(massage: "يرجى اختيار وسيلة دفع صحيحة"));
      return false;
    }

    return true;
  }
}
