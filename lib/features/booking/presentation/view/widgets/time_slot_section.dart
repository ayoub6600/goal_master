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
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class TimeSlotSection extends StatelessWidget {
  final PageController controller;
  const TimeSlotSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        if (state is TimeLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is TimeFailure) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.font16Bold.copyWith(color: Colors.red),
            ),
          );
        } else if (state is TimeSuccess) {
          final times = state.time;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepTitle(
                  title: "وقت الحجز",
                  description: "قم باختيار الوقت المناسب للحجز الذي تريده",
                ),
                HeightSpace(16.h),
                Wrap(
                  children: List.generate(times.length, (index) {
                    final time = times[index].startTime;
                    bool isSelected = state.selectedTime == time;

                    return GestureDetector(
                      onTap: () {
                        if (times[index].isAvailable == 0) return;

                        context.read<PageViewCubit>().nextPage();
                        controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );

// التاريخ المختار من CalendarCubit
                        final selectedDate =
                            context.read<CalendarCubit>().state.focusedDay;

// حول String الوقت إلى DateTime
                        final parts = time.split(':'); // لو time = "19:00:00"
                        final parsedTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          int.parse(parts[0]), // hour
                          int.parse(parts[1]), // minute
                          int.parse(parts[2]), // second
                        );

// حدد وقت البداية والنهاية
                        context.read<CalendarCubit>().selectTime(parsedTime);
                        context
                            .read<CalendarCubit>()
                            .selectTimeEnd(parsedTime.add(Duration(hours: 1)));
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 4.h),
                            padding: EdgeInsets.all(12.h),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: times[index].isAvailable == 0
                                    ? Colors
                                        .grey // ✅ جعل اللون أحمر في حال غير متاح
                                    : isSelected
                                        ? Colors.green
                                        : AppColors.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${formatToHour(time)} ",
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.font16Bold.copyWith(
                                    color: times[index].isAvailable == 0
                                        ? Colors.grey
                                        : isSelected
                                            ? Colors.white
                                            : const Color(0xff204523),
                                    // decoration: times[index].isAvailable == 0
                                    //     ? TextDecoration.lineThrough
                                    //     : TextDecoration.none,
                                  ),
                                ),
                                Text(
                                  " _ ${formatToHour(times[index].endTime)}  ",
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyles.font16Bold.copyWith(
                                    color: times[index].isAvailable == 0
                                        ? Colors.grey
                                        : isSelected
                                            ? Colors.white
                                            : const Color(0xff204523),
                                    // decoration: times[index].isAvailable == 0
                                    //     ? TextDecoration.lineThrough
                                    //     : TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          times[index].isAvailable == 0
                              ? Container(
                                  height: 1.h,
                                  width: 100.w,
                                  color: Colors.red,
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
