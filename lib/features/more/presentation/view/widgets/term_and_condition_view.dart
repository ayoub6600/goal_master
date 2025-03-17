import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class TermAndConditionView extends StatelessWidget {
  const TermAndConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        title: "الشروط والاحكام",
        allowBack: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightSpace(20.h),
              Text(
                "باستخدام هذا الموقع، فإنك توافق على الالتزام بكافة الشروط والأحكام المذكورة أدناه. إذا كنت لا توافق على هذه الشروط، يُرجى عدم استخدام الموقع.",
                style:
                    AppTextStyles.font16Bold.copyWith(color: AppColors.black),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ));
  }
}
