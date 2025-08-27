import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class CustomCalder extends StatelessWidget {
  const CustomCalder({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final calendarCubit = context.read<CalendarCubit>();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // الشهر الحالي + الشهر اللي بعده
        final firstOfMonth = DateTime(now.year, now.month, 1);
        final lastOfNextMonth = DateTime(now.year, now.month + 2, 0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepTitle(
                title: "تاريخ الحجز",
                description: "اختر التاريخ المناسب للحجز الذي تريده",
              ),
              TableCalendar(
                firstDay: firstOfMonth,
                lastDay: lastOfNextMonth,
                focusedDay: _clamp(
                  state.focusedDay,
                  firstOfMonth,
                  lastOfNextMonth,
                ),
                locale: 'ar_SA',
                selectedDayPredicate: (day) =>
                    isSameDay(state.selectedDay, day),
                enabledDayPredicate: (day) {
                  // يمنع الأيام الماضية
                  return !day.isBefore(today);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay.isBefore(today)) return;

                  calendarCubit.updateSelectedDay(
                    DateTime(
                        selectedDay.year, selectedDay.month, selectedDay.day),
                    DateTime(
                        selectedDay.year, selectedDay.month, selectedDay.day),
                  );

                  context.read<PageViewCubit>().nextPage();
                  controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );

                  final pv = context.read<PageViewCubit>().state;
                  calendarCubit.listTimeslot(
                    branchId: pv.clubId ?? 0,
                    employeeId: pv.employeeId ?? 0,
                    serviceId: pv.serviceId ?? 0,
                  );
                },
                calendarBuilders: CalendarBuilders(
                  outsideBuilder: (context, day, focusedDay) =>
                      _outsideCell(day),
                  todayBuilder: (context, day, focusedDay) =>
                      _dayCell(day, isToday: true),
                  selectedBuilder: (context, day, focusedDay) =>
                      _dayCell(day, isSelected: true),
                  defaultBuilder: (context, day, focusedDay) {
                    final isToday = isSameDay(day, today);
                    final isSelected = isSameDay(day, state.selectedDay);
                    return _dayCell(day,
                        isToday: isToday, isSelected: isSelected);
                  },
                  disabledBuilder: (context, day, focusedDay) =>
                      _disabledCell(day),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: false,
                  outsideDaysVisible: true,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static DateTime _clamp(DateTime focused, DateTime first, DateTime last) {
    if (focused.isBefore(first)) return first;
    if (focused.isAfter(last)) return last;
    return focused;
  }

  static Widget _dayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    Color bg = Colors.transparent;
    Color text = Colors.black;

    if (isSelected) {
      bg = const Color(0xFF2ECC71);
      text = Colors.white;
    } else if (isToday) {
      bg = const Color(0xFF3498DB).withOpacity(0.2);
      text = const Color(0xFF3498DB);
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  static Widget _outsideCell(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  static Widget _disabledCell(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(color: Colors.grey.withOpacity(0.5)),
      ),
    );
  }
}
