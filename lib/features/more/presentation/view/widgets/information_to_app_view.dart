import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class InformationToAppView extends StatelessWidget {
  const InformationToAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        title: "معلومات عن التطبيق",
        allowBack: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightSpace(20.h),
              Text(
                "تطبيقGoal Master هو منصتك الذكية لحجز الملاعب بسهولة وسرعة!  نوفر لك أفضل الملاعب لمختلف الرياضات بأفضل الأسعار، مع خيارات متعددة للحجز وإدارة مواعيد المباريات. احجز، ادفع إلكترونيًا، واستعد للعب بدون أي تعقيدا",
                style:
                    AppTextStyles.font16Bold.copyWith(color: AppColors.black),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ));
  }
}
