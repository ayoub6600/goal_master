import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalder extends StatelessWidget {
  const CustomCalder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CalendarCubit(),
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final calendarCubit = context.read<CalendarCubit>();

          return TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: state.focusedDay,
            selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              print("تم تحديد التاريخ: ${selectedDay.toLocal()}");
              calendarCubit.updateSelectedDay(selectedDay, focusedDay);
            },
            eventLoader: (day) => state.selectedEvents[day] ?? [],
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryBlueLight,
                shape: BoxShape.rectangle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
