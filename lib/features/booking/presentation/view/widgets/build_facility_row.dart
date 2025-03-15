import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class BuildFacilityRow extends StatelessWidget {
  const BuildFacilityRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          Assets.imagesPngImageLockersSvgrepoCom,
          fit: BoxFit.cover,
        ),
        WidthSpace(10.w),
        Text(
          "خزائن",
          style: AppTextStyles.font16Medium.copyWith(
            color: AppColors.fontColor,
          ),
        ),
      ],
    );
  }
}
