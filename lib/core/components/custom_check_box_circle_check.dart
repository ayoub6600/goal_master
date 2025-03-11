// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';

class CustomCheckBoxCircleCheck extends StatelessWidget {
  final bool active;
  final double? borderRadius;
  const CustomCheckBoxCircleCheck({
    super.key,
    this.active = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
          color: active ? AppColors.primary : null,
          borderRadius: BorderRadius.circular(borderRadius ?? 1000),
          border: Border.all(
            width: 1.5,
            color: active ? AppColors.primary : AppColors.inactive,
          )),
      child: active
          ? Icon(
              Icons.check,
              size: 15.r,
              color: Colors.white,
            )
          : null,
    );
  }
}
