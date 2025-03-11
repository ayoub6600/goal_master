import 'package:flutter/widgets.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class Otpviewbody extends StatelessWidget {
  const Otpviewbody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Padding(
        padding: EdgeInsets.all(20.0.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                Assets.imagesPngImageInactive,
                width: 300.w,
                height: 300.w,
              ),
              Text(
                "تحقق من OTP",
                style: AppTextStyles.font24Bold.copyWith(
                  color: Color(0xff418946),
                ),
              ),
              HeightSpace(16.h),
              Text(
                "ادخل الرمز المرسل الي الواتس اب الخاص بك",
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: AppColors.inactiveText1,
                ),
              ),
              HeightSpace(16.h),
              OtpTextField(
                numberOfFields: 4,
                fieldWidth: 64.w,
                borderWidth: 1,
                enabledBorderColor: AppColors.inactive2,
                focusedBorderColor: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
                borderColor: Color(0xFF512DA8),
                showFieldAsBox: true,
                onSubmit: (String verificationCode) {
                  //    cubit.setOTP(verificationCode);
                }, // end onSubmit
              ),
              HeightSpace(20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '00:39',
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  WidthSpace(8.w),
                  Text(
                    'اعادة ارسال',
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              HeightSpace(20.h),
              ButtonApp(
                text: 'تأكيد',
                backGround: AppColors.primary,
                onTap: () {
                  push(RoutesKeys.kNewPassword, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
