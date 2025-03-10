import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
          child: Column(
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
              // CustomTextField(
              //   hint: 'البريد الالكترونى',
              //   //   controller: cubit.emailController,
              //   inputType: TextInputType.emailAddress,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
