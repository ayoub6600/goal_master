import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/components/button_app.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Assets.imagesPngImageBackgroundLogin,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // width: 336.w,
          // height: 558.h,
          margin: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 100.h,
          ),
          padding: EdgeInsets.fromLTRB(16, 46, 16, 46),
          decoration: BoxDecoration(
            //color: Color(0x1AD9D9D9),
            color: Colors.grey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 1, color: Colors.transparent),

            gradient: LinearGradient(
              begin: Alignment(0.85, -0.53),
              end: Alignment(-0.85, 0.53),
              colors: [
                Color.fromRGBO(223, 245, 225, 0.05),
                Color.fromRGBO(97, 206, 105, 0.5),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 40.w,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "مرحبًا بعودتك!",
                        style: AppTextStyles.font24Bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      HeightSpace(24.h),
                      Text(
                        "سجّل حسابك واحجز ملعبك في لحظات",
                        style: AppTextStyles.font16Medium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      HeightSpace(48.h),
                    ],
                  ),
                ),
                Text(
                  "اسم المستخدم",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
                HeightSpace(8.h),
                CustomTextField(
                  hint: "اسم المستخدم",
                  //   controller: cubit.emailController,
                  inputType: TextInputType.emailAddress,
                ),
                HeightSpace(14.h),
                Text(
                  "كلمة السر",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
                HeightSpace(8.h),
                CustomTextField(
                  hint: "ضع كلمة السر",
                  password: true,
                  // controller: cubit.passwordController,
                ),
                HeightSpace(8.h),
                GestureDetector(
                  onTap: () {
                    push(RoutesKeys.kForgotPassword, context);
                  },
                  child: Text(
                    "هل نسيت كلمة المرور؟",
                    style: AppTextStyles.font14SemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                HeightSpace(50.h),
                ButtonApp(
                  text: "تسجيل الدخول",
                  backGround: AppColors.primary,
                  textColor: Colors.white,
                  onTap: () => push(RoutesKeys.kHome, context),
                ),
                HeightSpace(29.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "ليس لديك حساب؟",
                      style: AppTextStyles.font14SemiBold.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    WidthSpace(5.w),
                    InkWell(
                      onTap: () {
                        push(RoutesKeys.kRegister, context);
                      },
                      child: Text(
                        "انشئ حساب",
                        style: AppTextStyles.font14SemiBold.copyWith(
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
