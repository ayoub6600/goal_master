import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class StepTitle extends StatelessWidget {
  const StepTitle({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.font20Bold),
          SizedBox(height: 8.h),
          Text(
            description,
            style: AppTextStyles.font16Medium,
          ),
        ],
      ),
    );
  }
}
