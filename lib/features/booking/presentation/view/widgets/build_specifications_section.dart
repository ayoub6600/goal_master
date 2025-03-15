import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class BuildSpecificationsSection extends StatelessWidget {
  const BuildSpecificationsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Text(
          "ملعب سباعي نجيل صناعي مجهز بمعايير عالية، بأبعاد مثالية (50-65 م × 30-45 م) وإضاءة قوية للعب في أي وقت. مناسب للمباريات والتدريبات بأفضل جودة!",
          style: AppTextStyles.font14Medium.copyWith(
            color: AppColors.fontColor,
          ),
        ),
      ],
    );
  }
}
