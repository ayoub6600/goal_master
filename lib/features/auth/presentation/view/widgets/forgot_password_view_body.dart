import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/auth/presentation/manager/verify_email_cubit/verify_email_cubit.dart';

class ForgotPasswordViewBody extends StatelessWidget {
  const ForgotPasswordViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VerifyEmailCubit>();
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
              controller: cubit.emailController,
            ),
            HeightSpace(50.h),
            BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
              listener: (context, state) {
                if (state is VerifyResend) {
                  pushReplacement(
                    RoutesKeys.kOtp,
                    context,
                    extra: {
                      'phone': cubit.emailController.text,
                      'forget':
                          true, 
                    },
                  );
                } else if (state is VerifyEmailError) {
                  showCustomFailureToast(state.errMessage);
                }
              },
              builder: (context, state) {
                return ButtonApp(
                  text: "ارسال الرمز",
                  onTap: cubit.sendOTP,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
