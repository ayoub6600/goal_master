import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/time_slot_section.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalder extends StatelessWidget {
  const CustomCalder({super.key, required this.controller});
  final PageController controller;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final calendarCubit = context.read<CalendarCubit>();
        final lastDay = DateTime.now().add(Duration(days: 30));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepTitle(
                  title: "تاريخ الحجز",
                  description: "اختر التاريخ المناسب للحجز الذي تريده"),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: lastDay,
                focusedDay: state.focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(state.selectedDay, day),
                locale: 'ar_SA',
                onDaySelected: (selectedDay, focusedDay) {
                  context.read<PageViewCubit>().nextPage();
                  controller.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                  calendarCubit.updateSelectedDay(selectedDay, focusedDay);

                  final clubId = context.read<PageViewCubit>().state.clubId;
                  final employeeId =
                      context.read<PageViewCubit>().state.employeeId;
                  final serviceId =
                      context.read<PageViewCubit>().state.serviceId;

                  calendarCubit.listTimeslot(
                    branchId: clubId ?? 0,
                    employeeId: employeeId ?? 0,
                    serviceId: serviceId ?? 0,
                  );
                },
                calendarBuilders: CalendarBuilders(
                  outsideBuilder: (context, day, focusedDay) => Container(
                    margin: EdgeInsets.all(6),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  todayBuilder: (context, day, focusedDay) =>
                      buildDayCell(day, isToday: true),
                  selectedBuilder: (context, day, focusedDay) =>
                      buildDayCell(day, isSelected: true),
                  defaultBuilder: (context, day, focusedDay) {
                    return buildDayCell(
                      day,
                      isToday: isSameDay(day, DateTime.now()),
                      isSelected: isSameDay(day, state.selectedDay),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),
              ),
              const SizedBox(height: 16),
              //  TimeSlotSection(state: state, controller: controller),
            ],
          ),
        );
      },
    );
  }

  Widget buildDayCell(DateTime day,
      {bool isToday = false, bool isSelected = false}) {
    Color bgColor = Colors.transparent;
    Color textColor = Colors.black;

    if (isSelected) {
      bgColor = Colors.green;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = Colors.blue;
      textColor = Colors.black;
    }

    return Container(
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text('${day.day}', style: TextStyle(color: textColor)),
    );
  }
}
