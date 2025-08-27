import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';

import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class TopUpSheetVisa extends StatelessWidget {
  const TopUpSheetVisa({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Form(
        //   key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // عشان الـ sheet ياخد ارتفاع المحتوى
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ادخل  المبلغ",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: "ادخل المبلغ",
              //  controller: cubit.codeController,
              inputType: TextInputType.phone,
            ),
            HeightSpace(16.h),
            ButtonApp(
              text: "تأكيد الشحن",
              backGround: AppColors.primary,
              textColor: Colors.white,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
