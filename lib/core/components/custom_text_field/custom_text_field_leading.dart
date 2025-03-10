// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/spaces.dart';

class CustomTextFieldLeading extends StatelessWidget {
  final String? leadingIconPath;
  final Widget? leading;
  const CustomTextFieldLeading({
    super.key,
    this.leadingIconPath,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leadingIconPath != null)
          Row(
            children: [
              Image.asset(
                leadingIconPath!,
                width: 20.w,
              ),
              WidthSpace(8.w),
            ],
          ),
        if (leading != null) leading!,
      ],
    );
  }
}
