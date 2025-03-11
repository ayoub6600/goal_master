import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class UpdateProfileBody extends StatelessWidget {
  const UpdateProfileBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "تغيير معلوماتك الشخصية",
      allowBack: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeightSpace(24.h),
            Text(
              "اسم المستخدم",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: "اسم المستخدم",
              //   controller: cubit.emailController,
              inputType: TextInputType.emailAddress,
            ),
            HeightSpace(16.h),
            Text(
              "الاسم",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: "اكتب اسمك",
              //   controller: cubit.emailController,
              inputType: TextInputType.emailAddress,
            ),
            HeightSpace(16.h),
            Text(
              "رقم الهاتف",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: "اكتب رقم هاتفك",
              //   controller: cubit.emailController,
              inputType: TextInputType.emailAddress,
            ),
            HeightSpace(70.h),
            ButtonApp(text: " تحديث البيانات", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
