import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/auth/presentation/manager/change_password_cubit/change_password_cubit.dart';

class NewPasswordViewBody extends StatelessWidget {
  const NewPasswordViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ChangePasswordCubit>();
    return PageWrapper(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "أنشئ كلمة مرور جديدة",
              style: AppTextStyles.font24Bold.copyWith(color: AppColors.black),
            ),
            HeightSpace(16.h),
            SizedBox(
              width: 250.w,
              child: Text(
                "يُفضّل اختيار كلمة مرور قوية تحتوي على أرقام وحروف لضمان أمان حسابك",
                style: AppTextStyles.font14SemiBold.copyWith(
                  color: AppColors.inactiveText1,
                ),
              ),
            ),
            HeightSpace(32.h),
            Text(
              "كلمة المرور الجديدة",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: "ضع كلمة السر",
              password: true,
              controller: cubit.passwordController,
              inputType: TextInputType.text,
            ),
            HeightSpace(16.h),
            Text(
              'أعد ادخال كلمة المرور',
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: "أعد كلمة السر ",
              password: true,
              inputType: TextInputType.text,
              controller: cubit.confirmPasswordController,
            ),
            HeightSpace(100.h),
            BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                return ButtonApp(
                    text: "تحديث كلمة المرور", onTap: cubit.changePassword);
              },
            ),
          ],
        ),
      ),
    );
  }
}
