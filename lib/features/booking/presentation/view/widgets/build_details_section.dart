import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_facility_row.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_location_row.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_specifications_section.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_title_row.dart';

class BuildDetailsSection extends StatelessWidget {
  const BuildDetailsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BuildTitleRow(),
          HeightSpace(8.h),
          Text(
            "ملعب (7*7)",
            style: AppTextStyles.font16Bold.copyWith(
              color: AppColors.fontColor,
            ),
          ),
          HeightSpace(20.h),
          BuildLocationRow(),
          HeightSpace(30.h),
          BuildSpecificationsSection(),
          HeightSpace(30.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "مواصفات الملعب",
                style: AppTextStyles.font16Bold.copyWith(
                  color: AppColors.fontColor,
                ),
              ),
              HeightSpace(8.h),
              BuildFacilityRow(),
            ],
          ),
        ],
      ),
    );
  }
}
