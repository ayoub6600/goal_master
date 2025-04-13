import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/auth/presentation/manager/verify_email_cubit/verify_email_cubit.dart';

class Otpviewbody extends StatelessWidget {
  const Otpviewbody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VerifyEmailCubit>();
    var cubitWatch = context.watch<VerifyEmailCubit>();
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
              Directionality(
                textDirection: TextDirection.ltr,
                child: OtpTextField(
                  numberOfFields: 6,
                  //fieldWidth: 64.w,
                  borderWidth: 1,
                  enabledBorderColor: AppColors.inactive2,
                  focusedBorderColor: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                  borderColor: Color(0xFF512DA8),
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode) {
                    cubit.setOTP(verificationCode);
                  }, // end onSubmit
                ),
              ),
              HeightSpace(50.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!cubitWatch.allowResend)
                    Text(cubitWatch.timeString,
                        style: AppTextStyles.font16Bold.copyWith(
                          color: AppColors.primary,
                        )),
                  WidthSpace(8.w),
                  GestureDetector(
                    onTap: cubit.resend,
                    child: Text('اعادة ارسال',
                        style: AppTextStyles.font16Bold.copyWith(
                          color: cubitWatch.allowResend
                              ? AppColors.primary
                              : AppColors.inactiveText2,
                        )),
                  ),
                ],
              ),
              HeightSpace(30.h),
              BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
                listener: (context, state) {
                  print("---->state $state");
                  if (state is VerifyEmailSuccess) {
                    final forget = context.read<VerifyEmailCubit>().forget;

                    if (forget) {
                      // في حالة نسيت كلمة المرور
                      if (state.model.data.resetToken != null) {
                        pushReplacement(RoutesKeys.kNewPassword, context,
                            extra: state.model.data.resetToken);
                      }
                    } else {
                      // في حالة تسجيل دخول عادي
                      pushReplacement(RoutesKeys.kLogin, context);
                    }

                    showCustomSuccessToast(state.model.message);
                  } else if (state is VerifyEmailError) {
                    showCustomFailureToast(state.errMessage);
                    print(state..errMessage);
                  }
                  if (state is VerifyResend) {
                    showCustomSuccessToast(state.massage);
                  }
                },
                builder: (context, state) {
                  return ButtonApp(
                    text: 'تأكيد',
                    backGround: AppColors.primary,
                    onTap: cubit.verifyOTP,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
