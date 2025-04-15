import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/profail/presentation/manager/reset_password_cubit/reset_password_cubit.dart';

class ChangePasswordBody extends StatelessWidget {
  const ChangePasswordBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ResetPasswordCubit>();
    return PageWrapper(
        title: "تغيير كلمة المرور",
        allowBack: true,
        child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //  spacing: 16.h,
                children: [
                  Text(
                    "كلمة المرور الحالية",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  CustomTextField(
                    hint: "ضع كلمة السر الحالية",
                    password: true,
                    controller: cubit.oldPasswordController,
                    inputType: TextInputType.text,
                  ),
                  HeightSpace(16.h),
                  Text(
                    "كلمة المرور الجديدة",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  HeightSpace(8.h),
                  CustomTextField(
                    hint: "ضع كلمة السر الجديدة",
                    password: true,
                    inputType: TextInputType.text,
                    controller: cubit.newPasswordController,
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
                    hint: "أعد كلمة السر الجديدة ",
                    password: true,
                    inputType: TextInputType.text,
                    controller: cubit.newPasswordConformationController,
                  ),
                  HeightSpace(100.h),
                  BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                    listener: (context, state) {
                      if (state is ResetPasswordSuccess) {
                        go(RoutesKeys.kHome, context);
                        showCustomSuccessToast("تم تغيير كلمة المرور بنجاح");
                      } else if (state is ResetPasswordError) {
                        showCustomFailureToast(state.errMessage);
                      }
                    },
                    builder: (context, state) {
                      return ButtonApp(
                          text: "تحديث كلمة المرور",
                          onTap: cubit.resetPassword);
                    },
                  ),
                ])));
  }
}
