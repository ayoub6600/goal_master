import 'package:equatable/equatable.dart';

abstract class CalendarState extends Equatable {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<dynamic>> selectedEvents;
  final dynamic selectedTime;
  final DateTime? selectedTimeEnd; // Added selectedTimeEnd

  const CalendarState({
    required this.selectedDay,
    required this.focusedDay,
    required this.selectedEvents,
    this.selectedTime,
    this.selectedTimeEnd, // Pass selectedTimeEnd to constructor
  });

  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd to copyWith
  });

  @override
  List<Object?> get props =>
      [selectedDay, focusedDay, selectedEvents, selectedTime, selectedTimeEnd];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial({
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
          selectedTimeEnd: selectedTimeEnd, // Pass selectedTimeEnd here
        );

  @override
  CalendarInitial copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) {
    return CalendarInitial(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedTimeEnd:
          selectedTimeEnd ?? this.selectedTimeEnd, // Added selectedTimeEnd here
    );
  }
}

class TimeLoading extends CalendarState {
  TimeLoading({
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
          selectedTimeEnd: selectedTimeEnd, // Pass selectedTimeEnd here
        );

  @override
  TimeLoading copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) {
    return TimeLoading(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedTimeEnd:
          selectedTimeEnd ?? this.selectedTimeEnd, // Added selectedTimeEnd here
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
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
          selectedTimeEnd: selectedTimeEnd, // Pass selectedTimeEnd here
        );

  @override
  TimeSuccess copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) {
    return TimeSuccess(
      time: time,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedTimeEnd:
          selectedTimeEnd ?? this.selectedTimeEnd, // Added selectedTimeEnd here
    );
  }

  @override
  List<Object?> get props => [
        time,
        selectedDay,
        focusedDay,
        selectedEvents,
        selectedTime,
        selectedTimeEnd
      ];
}

class TimeFailure extends CalendarState {
  final String message;

  TimeFailure({
    required this.message,
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<dynamic>> selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) : super(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          selectedEvents: selectedEvents,
          selectedTime: selectedTime,
          selectedTimeEnd: selectedTimeEnd, // Pass selectedTimeEnd here
        );

  @override
  TimeFailure copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<dynamic>>? selectedEvents,
    dynamic selectedTime,
    DateTime? selectedTimeEnd, // Added selectedTimeEnd
  }) {
    return TimeFailure(
      message: message,
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedEvents: selectedEvents ?? this.selectedEvents,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedTimeEnd:
          selectedTimeEnd ?? this.selectedTimeEnd, // Added selectedTimeEnd here
    );
  }

  @override
  List<Object?> get props => [
        message,
        selectedDay,
        focusedDay,
        selectedEvents,
        selectedTime,
        selectedTimeEnd
      ];
}
