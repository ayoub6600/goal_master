import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class BuildTitleRow extends StatelessWidget {
  const BuildTitleRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "ملعب سباعي",
          style: AppTextStyles.font20Bold.copyWith(
            color: Color(0xff204523),
          ),
        ),
        Spacer(),
        //rating widget
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
                children: List.generate(
              5,
              (index) => Image.asset(
                Assets.imagesPngImageStar,
                fit: BoxFit.cover,
              ),
            )),
            WidthSpace(8.w),
            Text(
              "4.5",
              style: AppTextStyles.font16Bold.copyWith(
                color: AppColors.fontColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
