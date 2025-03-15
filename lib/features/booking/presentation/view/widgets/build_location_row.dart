import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class BuildLocationRow extends StatelessWidget {
  const BuildLocationRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Image.asset(
              Assets.imagesPngImageLocation,
              fit: BoxFit.cover,
            ),
            WidthSpace(10.w),
            Text(
              "ليبيا - المصراتة",
              style: AppTextStyles.font16Medium.copyWith(
                color: AppColors.fontColor,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: AppColors.primary),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Image.asset(
                Assets.imagesPngImageArrow,
                fit: BoxFit.cover,
              ),
              WidthSpace(10.w),
              Text(
                "الاتجاهات",
                style: AppTextStyles.font16Medium.copyWith(
                  color: AppColors.fontColor,
                ),
              ),
            ],
          ),
        ),
        //rating widget
      ],
    );
  }
}
