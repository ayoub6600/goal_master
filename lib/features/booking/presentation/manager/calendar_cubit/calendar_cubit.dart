import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit()
      : super(CalendarState(
          selectedDay: DateTime.now(),
          focusedDay: DateTime.now(),
          selectedEvents: {},
        ));

  void updateSelectedDay(DateTime selectedDay, DateTime focusedDay) {
    emit(state.copyWith(selectedDay: selectedDay, focusedDay: focusedDay));
    print("تم تحديد التاريخ: ${selectedDay.toLocal()}");
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
