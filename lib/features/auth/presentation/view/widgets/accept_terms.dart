// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_check_box_circle_check.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class AcceptTerms extends StatelessWidget {
  final bool accepted;
  final VoidCallback? toggleAccepted;
  const AcceptTerms({
    super.key,
    this.accepted = false,
    this.toggleAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleAccepted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCheckBoxCircleCheck(
            borderRadius: 5.r,
            active: accepted,
          ),
          WidthSpace(8.w),
          Expanded(
            child: Text(
              "أوافق علي الشوط والاحكام",
              textAlign: TextAlign.start,
              style: AppTextStyles.font16Bold.copyWith(
                //  size: 16,
                color: AppColors.uiBlack,
                //  weight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
