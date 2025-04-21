import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:intl/intl.dart';

part 'add_booking_state.dart';

class AddBookingCubit extends Cubit<AddBookingState> {
  AddBookingCubit(this.bookingRepo) : super(AddBookingInitial());

  final BookingRepo bookingRepo;
  int _paymentType = 0; // default is cash

  void setPaymentType(int value) {
    _paymentType = value;
  }

  Future<void> addBooking({
    required int employeeId,
    required int serviceId,
    required int zoneId,
    required int clubId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    emit(AddBookingLoading());

    String formattedDate = _formatDate(date);
    print("formattedDate: $startTime");
    print("formattedDate: $endTime");
    if (!_validateBookingData(
      employeeId: employeeId,
      serviceId: serviceId,
      zoneId: zoneId,
      clubId: clubId,
      date: formattedDate,
      startTime: startTime,
      endTime: endTime,
    )) return;

    String fullname = SharedPreferenceUtil.getString(PrefKey.fullName);
    String phone = SharedPreferenceUtil.getString(PrefKey.phone);

    final result = await bookingRepo.addBooking(
      branchId: clubId,
      employeeId: employeeId,
      serviceId: serviceId,
      paymentType: _paymentType,
      date: formattedDate,
      startTime: startTime,
      endTime: endTime,
      fullName: fullname,
      phone: phone,
      state: '1',
    );

    result.fold(
      (failure) => emit(AddBookingFailure(massage: failure.errMessage)),
      (data) => emit(AddBookingSuccess(massage: data)),
    );
  }

  // تنسيق التاريخ إلى yyyy-MM-dd
  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  bool _validateBookingData({
    required int employeeId,
    required int serviceId,
    required int zoneId,
    required int clubId,
    required String date,
    required String startTime,
    required String endTime,
  }) {
    if (employeeId == 0 || serviceId == 0 || zoneId == 0 || clubId == 0) {
      emit(
          const AddBookingFailure(massage: "يرجى اختيار جميع الحقول المطلوبة"));
      return false;
    }

    if (date.isEmpty || startTime.isEmpty || endTime.isEmpty) {
      emit(const AddBookingFailure(massage: "يرجى اختيار التاريخ والوقت"));
      return false;
    }

    if (_paymentType != 1 && _paymentType != 4) {
      emit(const AddBookingFailure(massage: "يرجى اختيار وسيلة دفع صحيحة"));
      return false;
    }

    // التحقق من أن المدة ساعة على الأقل
    try {
      final start = DateFormat("HH:mm").parse(startTime);
      final end = DateFormat("HH:mm").parse(endTime);
      final difference = end.difference(start);

      if (difference.inMinutes < 60) {
        emit(const AddBookingFailure(
            massage: "يجب أن يكون الحجز لمدة ساعة على الأقل"));
        return false;
      }
    } catch (e) {
      emit(const AddBookingFailure(massage: "تنسيق الوقت غير صالح"));
      return false;
    }

    return true;
  }
}
