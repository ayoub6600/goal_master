import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_facility_row.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_location_row.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_specifications_section.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_title_row.dart';

class BuildDetailsSection extends StatelessWidget {
  const BuildDetailsSection({
    super.key,
    required this.booking,
  });
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BuildTitleRow(
            booking: booking,
          ),
          HeightSpace(8.h),
          Text(
            " ${booking.remarks}",
            style: AppTextStyles.font16Bold.copyWith(
              color: AppColors.fontColor,
            ),
          ),
          HeightSpace(20.h),
          BuildLocationRow(
            booking: booking,
          ),
          HeightSpace(30.h),
          BuildSpecificationsSection(),
          HeightSpace(30.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "تفاصيل الحجز",
                style: AppTextStyles.font16Bold.copyWith(
                  color: AppColors.fontColor,
                ),
              ),
              HeightSpace(8.h),
              BuildFacilityRow(
                booking: booking,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
