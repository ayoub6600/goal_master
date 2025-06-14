import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/onboarding/presentation/view/onboarding_view.dart';

class BuildHeaderImage extends StatelessWidget {
  const BuildHeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        SizedBox(
          height: 270.h,
          child: ClipPath(
            clipper: ShapePainter(),
            child: Image.asset(
              Assets.imagesPngImageBackgroundLogin,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 20.h,
          right: 20.w,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.asset(
              Assets.imagesPngImageArrowSquareRight,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
