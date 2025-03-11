import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class ForgotPasswordViewBody extends StatelessWidget {
  const ForgotPasswordViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Padding(
        padding: EdgeInsets.all(20.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "نسيت كلمة المرور",
              style: AppTextStyles.font24Bold.copyWith(color: AppColors.black),
            ),
            HeightSpace(16.h),
            SizedBox(
              width: 250.w,
              child: Text(
                "ادخل رقم هاتف الواتس اب لاستلام الرمز لتعيين كلمة مرور جديدة",
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: AppColors.inactiveText1,
                ),
              ),
            ),
            HeightSpace(32.h),
            CustomTextField(
              hint: "ادخل رقم هاتف الواتس اب",
              //  password: true,
              // controller: cubit.passwordController,
            ),
            HeightSpace(50.h),
            ButtonApp(
              text: "ارسال الرمز",
              onTap: () {
                push(RoutesKeys.kOtp, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
