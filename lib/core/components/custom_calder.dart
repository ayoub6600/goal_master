import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/format_to_hour.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalder extends StatelessWidget {
  const CustomCalder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final calendarCubit = context.read<CalendarCubit>();

        return Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: state.focusedDay,
              selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                calendarCubit.updateSelectedDay(selectedDay, focusedDay);
                calendarCubit.listTimeslot();
                print("تم تحديد التاريخ: ${selectedDay.toLocal()}");
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
            ),
            const SizedBox(height: 16),
            _TimeSlotSection(state: state),
          ],
        );
      },
    );
  }
}

class _TimeSlotSection extends StatelessWidget {
  final CalendarState state;

  const _TimeSlotSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is TimeLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is TimeFailure) {
      return Center(
        child: Text(
          (state as TimeFailure).message,
          style: AppTextStyles.font16Bold.copyWith(color: Colors.red),
        ),
      );
    } else if (state is TimeSuccess) {
      final times = (state as TimeSuccess).time;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "وقت الحجز",
            style: AppTextStyles.font16Bold.copyWith(color: Colors.black),
          ),
          HeightSpace(16.h),
          Wrap(
            children: List.generate(times.length, (index) {
              final time = times[index].startTime; // Use actual time
              return GestureDetector(
                onTap: () {
                  context.read<CalendarCubit>().selectTime(time);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: state.selectedTime == time
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Text(
                    formatToHour(time), // Format time display
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Color(0xff204523),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
