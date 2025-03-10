// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';

class CustomTextFieldContainer extends StatelessWidget {
  final Widget child;
  final Duration animationDuration;
  final GlobalKey containerKey;
  final FocusNode focusNode;
  final int? maxLines;
  final int? minLines;

  const CustomTextFieldContainer({
    super.key,
    required this.child,
    required this.animationDuration,
    required this.containerKey,
    required this.focusNode,
    this.maxLines,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    int differenceMax = (maxLines ?? 1) - 1;
    int differenceMin = (minLines ?? 1) - 1;
    double lineHeight = 18; // تقليل ارتفاع السطر

    return AnimatedContainer(
      duration: animationDuration,
      constraints: BoxConstraints(
        maxHeight: ((differenceMax * lineHeight + 50)).h, // تقليل القيمة
        minHeight: (differenceMin * lineHeight + 50).h, // تقليل القيمة
      ),
      key: containerKey,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r), // تقليل الزوايا
      ),
      child: child,
    );
  }
}
