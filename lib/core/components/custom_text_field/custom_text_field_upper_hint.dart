// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFieldUpperHint extends StatelessWidget {
  const CustomTextFieldUpperHint({
    super.key,
    required this.animationDuration,
    required this.topSpace,
    required this.hintDown,
    this.hintStyle,
    this.hint,
    required this.hintKey,
  });

  final Duration animationDuration;
  final double topSpace;
  final bool hintDown;
  final GlobalKey hintKey;
  final TextStyle? hintStyle;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: animationDuration,
      curve: Curves.easeInOut,
      top: topSpace,
      right: 0,
      child: AnimatedDefaultTextStyle(
        style: hintStyle ??
            GoogleFonts.ibmPlexSansArabic(
              color: AppColors.inactiveText1,
              fontSize: hintDown ? 16.sp : 12.sp,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
        duration: animationDuration,
        child: Text(
          hint ?? '',
          key: hintKey,
        ),
      ),
    );
  }
}
