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

  Future<void> listTimeslot({
    required int branchId,
    required int employeeId,
    required int serviceId,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(state.selectedDay);

    emit(TimeLoading());
    final result = await bookingRepo.listTimeslot(
      branchId: branchId,
      employeeId: employeeId,
      serviceId: serviceId,
      date: formattedDate, // Provide appropriate date format if needed
    );
    result.fold(
      (failure) => emit(TimeFailure(message: failure.errMessage)),
      (time) {
        print("---->time: ${time[0].startTime}");
        emit(TimeSuccess(time: time));
      },
    );
  }

  void selectTime(dynamic time) {
    emit(state.copyWith(selectedTime: time));
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
