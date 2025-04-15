import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class EmptyLoading extends StatelessWidget {
  const EmptyLoading({super.key, required this.title, required this.image});
  final String title;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            width: 180.w,
            height: 200.w,
            color: AppColors.grey,
          ),
          HeightSpace(20.h),
          Text(
            title,
            style: AppTextStyles.font14SemiBold,
          ),
        ],
      ),
    );
  }
}
