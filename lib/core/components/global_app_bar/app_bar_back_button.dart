import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/components/custom_button_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/assets.dart';

class AppBarBackButton extends StatelessWidget {
  final bool alwaysVisible;
  final bool allowBack;
  final Color? bgColor;
  final Color? iconColor;
  final Color? borderColor;
  final String? iconPath;
  final VoidCallback? onTap;
  const AppBarBackButton({
    super.key,
    this.alwaysVisible = false,
    this.allowBack = true,
    this.bgColor,
    this.iconColor,
    this.borderColor,
    this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: !allowBack
          ? 0
          : alwaysVisible
              ? 1
              : GoRouter.of(context).canPop()
                  ? 1
                  : 0,
      child: CustomButtonWrapper(
        padding: EdgeInsets.all(12.r),
        onTap: onTap ??
            () {
              GoRouter.of(context).pop();
            },
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            width: 1,
            color: borderColor ?? AppColors.inactive2,
          ),
          color: bgColor,
        ),
        child: Image.asset(
          iconPath ?? Assets.imagesPngImageArrowSquareRight,
          color: iconColor,
        ),
      ),
    );
  }
}
