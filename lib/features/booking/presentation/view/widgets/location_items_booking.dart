import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';

class LocationItemsBooking extends StatelessWidget {
  const LocationItemsBooking({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        image: DecorationImage(
            image: AssetImage(Assets.imagesPngImageBackgroundLogin),
            fit: BoxFit.cover),
      ),
      child: Center(
        child: Text(
          title,
          textDirection: TextDirection.ltr,
          style: AppTextStyles.font16Bold.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
