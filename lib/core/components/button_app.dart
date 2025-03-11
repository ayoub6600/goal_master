import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class ButtonApp extends StatelessWidget {
  const ButtonApp(
      {super.key,
      required this.text,
      this.textColor,
      this.backGround,
      this.onTap});
  final String text;
  final Color? backGround;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.h),
        decoration: BoxDecoration(
          color: backGround ?? Color(0xff418946),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.font16Bold.copyWith(
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
