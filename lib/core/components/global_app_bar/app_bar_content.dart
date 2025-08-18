// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/global_app_bar/app_bar_back_button.dart';
import 'package:goal_master/core/styles/spaces.dart';

class AppBarContent extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final bool backAlwaysVisible;
  final bool allowBack;
  final Color? backBgColor;
  final Color? backIconColor;
  final Color? backBorderColor;
  final EdgeInsets? padding;

  const AppBarContent({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.trailing,
    this.backAlwaysVisible = false,
    this.allowBack = true,
    this.backBgColor,
    this.backIconColor,
    this.backBorderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          HeightSpace(2.h),
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  leading ??
                      AppBarBackButton(
                        alwaysVisible: backAlwaysVisible,
                        allowBack: allowBack,
                        borderColor: backBorderColor,
                        iconColor: backIconColor,
                        bgColor: backBgColor,
                        onTap: () => Navigator.pop(context, true),
                      ),
                  if (trailing != null) trailing!,
                  titleWidget ??
                      (title == null
                          ? SizedBox()
                          : Text(
                              title!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
