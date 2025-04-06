import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/format_to_hour.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';

class BuildFacilityRow extends StatelessWidget {
  const BuildFacilityRow({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          icon: Assets.imagesPngImageCalendar,
          label: '',
          value: formatDate(booking.date),
        ),
        HeightSpace(6.h),
        _buildInfoRow(
          icon: Assets.imagesPngImageClock,
          label: '',
          value: '${formatToHour(booking.startTime)} ',
        ),
        HeightSpace(6.h),
        _buildInfoRow(
          icon: Assets.imagesPngImageClock,
          label: '',
          value: ' ${formatToHour(booking.endTime)}',
        ),
        HeightSpace(20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "السعر ",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: AppColors.fontColor,
                  ),
                ),
                HeightSpace(8.h),
                Text(
                  "دينار${booking.serviceAmount}",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        HeightSpace(6.h),
      ],
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(icon, width: 20.w),
        WidthSpace(8.w),
        Expanded(
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                  text: '$label ',
                  style: AppTextStyles.font14Medium
                      .copyWith(color: AppColors.primary),
                  children: [
                    TextSpan(
                      text: value,
                      style: AppTextStyles.font14Regular
                          .copyWith(color: AppColors.fontColor),
                    ),
                  ],
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
