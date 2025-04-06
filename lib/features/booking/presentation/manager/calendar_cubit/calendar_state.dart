import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarState {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<dynamic>> selectedEvents;

  CalendarState({
    required this.selectedDay,
    required this.focusedDay,
    required this.selectedEvents,
  });

  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
    );
  }
}
