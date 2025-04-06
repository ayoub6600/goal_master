import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.child,
  });
  final String title;
  final String icon;
  final Function()? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              fit: BoxFit.cover,
            ),
            WidthSpace(16.w),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.font16Bold.copyWith(
                      color: AppColors.fontColor,
                    ),
                  ),
                ],
              ),
            ),
            child != null
                ? SizedBox()
                : Image.asset(
                    Assets.imagesPngImageArrowLeft,
                    fit: BoxFit.cover,
                  ),
          ],
        ),
      ),
    );
  }
}
