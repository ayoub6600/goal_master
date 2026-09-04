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

  /// Wallet, pre-selected.
  ///
  /// It used to start at 0 — no method at all — so a customer who read the
  /// page and pressed "احجز" without noticing the choice was refused for a
  /// reason that was not their mistake. Wallet is the sensible default: it
  /// confirms instantly and needs nothing from the venue. Pay-on-arrival
  /// remains one tap away for anyone who wants it.
  int _paymentType = 4; // PaymentType::UserBalance
  bool _isSubmitting = false;

  /// Stable for as long as the customer stays on one checkout. Regenerated
  /// only after a booking actually succeeds, so a retry after a timeout or a
  /// double-tapped confirm reuses it and the backend can reject the repeat
  /// instead of spending the customer's coins twice.
  String? _checkoutReference;

  void setPaymentType(int value) {
    _paymentType = value;
  }

  /// The payment method chosen on this checkout. Exposed so the recurring
  /// booking flow can read the same choice rather than tracking its own — a
  /// second copy could disagree with what the customer selected.
  int get selectedPaymentType => _paymentType;

  /// Called when a checkout screen opens, so each new booking attempt gets its
  /// own reference.
  void beginCheckout() {
    _checkoutReference =
        'chk_${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(this)}';
  }

  Future<void> addBooking({
    required int employeeId,
    required int serviceId,
    required int zoneId,
    required int clubId,
    required String date,
    required dynamic startTime, // String or DateTime
    required dynamic endTime, // String or DateTime
    // The server's authoritative occurrence datetimes. Sent so the backend
    // can prove `date`/`startTime`/`endTime` describe the same moment it
    // offered, instead of trusting a bare calendar date.
    String? startAt,
    String? endAt,
    int coinsToRedeem = 0,
  }) async {
    if (_isSubmitting) {
      return;
    }

    _isSubmitting = true;
    emit(AddBookingLoading());

    String formattedDate = _formatDate(date);

    // Convert time to "HH:mm:ss" based on type
    String formattedStartTime = _formatTime(startTime);
    String formattedEndTime = _formatTime(endTime);

    print("startTime: $formattedStartTime");
    print("endTime: $formattedEndTime");

    // The duration check needs real timestamps, not clocks. A 23:00 → 00:00
    // booking is an hour long, but as two bare clock values it reads as minus
    // twenty-three hours and gets refused for being too short. `start_at` and
    // `end_at` already carry the day; fall back to the raw arguments for
    // callers that have none.
    if (!_validateBookingData(
      employeeId: employeeId,
      serviceId: serviceId,
      zoneId: zoneId,
      clubId: clubId,
      date: formattedDate,
      startTime: DateTime.tryParse(startAt ?? '') ?? startTime,
      endTime: DateTime.tryParse(endAt ?? '') ?? endTime,
    )) {
      _isSubmitting = false;
      return;
    }

    String fullname = SharedPreferenceUtil.getString(PrefKey.fullName);
    String phone = SharedPreferenceUtil.getString(PrefKey.phone);

    final result = await bookingRepo.addBooking(
      branchId: clubId,
      employeeId: employeeId,
      serviceId: serviceId,
      paymentType: _paymentType,
      date: formattedDate,
      startTime: formattedStartTime,
      endTime: formattedEndTime,
      startAt: startAt,
      endAt: endAt,
      fullName: fullname,
      phone: phone,
      state: '1',
      coinsToRedeem: coinsToRedeem,
      checkoutReference: _checkoutReference ??=
          'chk_${DateTime.now().microsecondsSinceEpoch}',
    );

    result.fold(
      (failure) {
        _isSubmitting = false;
        emit(AddBookingFailure(massage: failure.errMessage));
      },
      (data) {
        _isSubmitting = false;
        // Consumed — a genuinely new booking must not reuse this reference,
        // or the backend would reject it as a duplicate.
        _checkoutReference = null;
        emit(AddBookingSuccess(massage: data, coinsRedeemed: coinsToRedeem));
      },
    );
  }

  /// Format time if it's DateTime, otherwise return as-is.
  String _formatTime(dynamic time) {
    if (time is String) {
      return time;
    } else if (time is DateTime) {
      return DateFormat("HH:mm:ss").format(time);
    } else {
      throw FormatException("Invalid time format");
    }
  }

  /// Format date to yyyy-MM-dd
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
    required dynamic startTime,
    required dynamic endTime,
  }) {
    if (employeeId == 0 || serviceId == 0 || zoneId == 0 || clubId == 0) {
      emit(
          const AddBookingFailure(massage: "يرجى اختيار جميع الحقول المطلوبة"));
      return false;
    }

    if (date.isEmpty || startTime == null || endTime == null) {
      emit(const AddBookingFailure(massage: "يرجى اختيار التاريخ والوقت"));
      return false;
    }

    if (_paymentType != 1 && _paymentType != 4) {
      emit(const AddBookingFailure(massage: "يرجى اختيار وسيلة دفع صحيحة"));
      return false;
    }

    try {
      DateTime start = (startTime is DateTime)
          ? startTime
          : DateFormat("HH:mm:ss").parse(startTime);
      DateTime end = (endTime is DateTime)
          ? endTime
          : DateFormat("HH:mm:ss").parse(endTime);

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
