import 'package:equatable/equatable.dart';

abstract class CalendarState extends Equatable {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<dynamic>> selectedEvents;
  final dynamic selectedTime;

  const CalendarState({
    required this.selectedDay,
    required this.focusedDay,
    required this.selectedEvents,
    this.selectedTime,
  });

  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
  });

  @override
  List<Object?> get props =>
      [selectedDay, focusedDay, selectedEvents, selectedTime];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial({
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
        );

  @override
  CalendarInitial copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
  }) {
    return CalendarInitial(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

class TimeLoading extends CalendarState {
  TimeLoading({
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
        );

  @override
  TimeLoading copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
  }) {
    return TimeLoading(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

class TimeSuccess extends CalendarState {
  final List<dynamic> time;

  TimeSuccess({
    required this.time,
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
        );

  @override
  TimeSuccess copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
  }) {
    return TimeSuccess(
      time: time,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  @override
  List<Object?> get props =>
      [time, selectedDay, focusedDay, selectedEvents, selectedTime];
}

class TimeFailure extends CalendarState {
  final String message;

  TimeFailure({
    required this.message,
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
        );

  @override
  TimeFailure copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
  }) {
    return TimeFailure(
      message: message,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  @override
  List<Object?> get props =>
      [message, selectedDay, focusedDay, selectedEvents, selectedTime];
}
