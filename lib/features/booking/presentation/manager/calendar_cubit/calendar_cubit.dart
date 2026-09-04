import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:intl/intl.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final BookingRepo bookingRepo;

  CalendarCubit(this.bookingRepo)
      : super(CalendarInitial(
          selectedDay: DateTime.now(),
          focusedDay: DateTime.now(),
          selectedEvents: {},
        ));

  void updateSelectedDay(DateTime selectedDay, DateTime focusedDay) {
    emit(state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
    ));
    print("تم تحديد التاريخ: ${selectedDay.toLocal()}");
  }

  /// Load the whole night the customer picked.
  ///
  /// `employeeId` is gone from the signature: the time band is an internal
  /// scheduling detail the server resolves per slot. The selected day is the
  /// OPERATIONAL night, so slots after midnight come back carrying the
  /// following calendar date — and this cubit never adds a day to anything.
  Future<void> listTimeslot({
    required int branchId,
    required int serviceId,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(state.selectedDay);

    emit(TimeLoading(
      selectedDay: state.selectedDay,
      focusedDay: state.focusedDay,
      selectedEvents: state.selectedEvents,
      selectedTime: state.selectedTime,
    ));

    final result = await bookingRepo.listNightSlots(
      branchId: branchId,
      serviceId: serviceId,
      operationalDate: formattedDate,
    );

    result.fold(
      (failure) => emit(TimeFailure(
        message: failure.errMessage,
        selectedDay: state.selectedDay,
        focusedDay: state.focusedDay,
        selectedEvents: state.selectedEvents,
        selectedTime: state.selectedTime,
      )),
      (time) {
        emit(TimeSuccess(
          time: time,
          selectedDay: state.selectedDay,
          focusedDay: state.focusedDay,
          selectedEvents: state.selectedEvents,
          selectedTime: state.selectedTime,
        ));
      },
    );
  }

  void selectTime(dynamic time) {
    emit(state.copyWith(selectedTime: time));
  }

  void selectTimeEnd(DateTime endTime) {
    emit(state.copyWith(selectedTimeEnd: endTime));
  }

  void addEvent(DateTime day, dynamic event) {
    final newEvents = Map<DateTime, List<dynamic>>.from(state.selectedEvents);
    if (!newEvents.containsKey(day)) {
      newEvents[day] = [];
    }
    newEvents[day]!.add(event);
    emit(state.copyWith(selectedEvents: newEvents));
  }
}
