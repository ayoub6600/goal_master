import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/presentation/view/widgets/format_time.dart';

class BookingItem extends StatelessWidget {
  const BookingItem({super.key, required this.booking});
  final BookingSlot booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xfff5f7fa),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        color: Color(0xfff5f7fa),
        child: Row(
          children: [
            //display image
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8.r),
            //   child: Image.asset(
            //     Assets.imagesPngImage1,
            //     fit: BoxFit.cover,
            //     width: 80.w,
            //     // height: 80.h,
            //   ),
            // ),
            WidthSpace(8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "${booking.serviceTitle}",
                    style: AppTextStyles.font16Bold,
                  ),
                  HeightSpace(8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.watch_later_outlined,
                              color: AppColors.primary,
                            ),
                            WidthSpace(8.w),
                            Text(
                              "${formatTime(booking.startTime)} - ${formatTime(booking.endTime)}",
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.font14Bold.copyWith(
                                color: AppColors.fontColor,
                              ),
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Assets.imagesPngImageCalendar,
                            color: AppColors.primary,
                          ),
                          WidthSpace(8.w),
                          Text(
                            "${booking.date}",
                            style: AppTextStyles.font14Bold.copyWith(
                              color: AppColors.fontColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  HeightSpace(16.h),
                  ButtonApp(
                    text: "حجز",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
