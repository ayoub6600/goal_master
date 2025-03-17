import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class ItemsFavoriteStadium extends StatelessWidget {
  const ItemsFavoriteStadium({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224.w,
      // height: 250.h,
      // padding:  EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            width: 1,
            color: AppColors.primary,
          )),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.asset(
                Assets.imagesPngImageImageSta,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 126.h,
              ),
            ),
          ),
          HeightSpace(16.h),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0.w,
              vertical: 16.h,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        " كرة قدم",
                        style: AppTextStyles.font16Bold
                            .copyWith(color: AppColors.black),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "4",
                          style: AppTextStyles.font16Bold
                              .copyWith(color: AppColors.fontColor),
                        ),
                        Image.asset(
                          Assets.imagesPngImageStar,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ],
                ),
                HeightSpace(20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "السعر",
                        style: AppTextStyles.font14Medium
                            .copyWith(color: AppColors.grey),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "60/ H",
                          style: AppTextStyles.font16Bold
                              .copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          ButtonApp(text: "احجز الان", onTap: () {}),
        ],
      ),
    );
  }
}
