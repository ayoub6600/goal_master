import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/accept_terms.dart';

class RegisterViewBody extends StatelessWidget {
  const RegisterViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        allowBack: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "مرحبًا بك في جول ماستر",
                        style: AppTextStyles.font24Bold
                            .copyWith(color: AppColors.primary),
                      ),
                      HeightSpace(16.h),
                      SizedBox(
                        height: 57.h,
                        width: 250.w,
                        child: Text(
                          "أنشئ حسابك في خطوات بسيطة واستمتع بحجز الملاعب والمباريات بسهولة",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.font14SemiBold.copyWith(
                            color: AppColors.inactiveText1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  inputType: TextInputType.text,
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
                  isPhone: true,
                  //   controller: cubit.emailController,
                  inputType: TextInputType.phone,
                ),
                HeightSpace(16.h),
                Text(
                  "كلمة المرور",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: Colors.black,
                  ),
                ),
                HeightSpace(8.h),
                CustomTextField(
                  hint: "ضع كلمة السر",
                  password: true,

                  //   controller: cubit.emailController,
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
                ),
                HeightSpace(24.h),
                AcceptTerms(),
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
                        push(RoutesKeys.kLogin, context);
                      },
                      child: Text(
                        "تسجيل الدخول",
                        style: AppTextStyles.font14SemiBold.copyWith(
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                    ),
                  ],
                ),
                HeightSpace(40.h),
                ButtonApp(text: "تسجيل", backGround: AppColors.primary),
                HeightSpace(29.h),
              ],
            ),
          ),
        ));
  }
}
