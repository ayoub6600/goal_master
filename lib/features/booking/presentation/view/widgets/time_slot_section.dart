import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/format_to_hour.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';

class TimeSlotSection extends StatelessWidget {
  final CalendarState state;
  final PageController controller;
  const TimeSlotSection(
      {super.key, required this.state, required this.controller});

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
              bool isSelected = state.selectedTime == time;

              return GestureDetector(
                onTap: () {
                  //nextPage
                  context.read<PageViewCubit>().nextPage();
                  controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease);
                  // Handle time selection

                  context.read<CalendarCubit>().selectTime(time);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: times[index].isAvailable == 0
                          ? Colors.grey
                          : isSelected
                              ? Colors.green
                              : AppColors.primary,
                    ),
                  ),
                  child: Text(
                    formatToHour(time), // Format time display
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.font16Bold.copyWith(
                      color: times[index].isAvailable == 0
                          ? Colors.grey
                          : isSelected
                              ? Colors.white
                              : Color(0xff204523),
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
