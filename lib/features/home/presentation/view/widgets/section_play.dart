import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class SectionPlay extends StatelessWidget {
  const SectionPlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            width: 1,
            color: AppColors.primary,
          )),
      child: Column(
        children: [
          Image.asset(
            Assets.imagesPngImageActionOnProfessional,
            fit: BoxFit.cover,
            // width: 180.w,
            height: 100.h,
          ),
          HeightSpace(16.h),
          Text(
            " كرة قدم",
            style: AppTextStyles.font16Bold.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
