import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class ItemsNotification extends StatelessWidget {
  const ItemsNotification({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Color(0xffF4F6F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            Assets.imagesPngImageSoccerBall,
            fit: BoxFit.cover,
          ),
          WidthSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "جول ماستر تعلن عن المباره النهائية يوم الاحد...",
                  style: AppTextStyles.font14SemiBold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "1m ago.",
                  style: AppTextStyles.font14SemiBold,
                ),
              ],
            ),
          ),
          WidthSpace(12.w),
          CircleAvatar(
            radius: 12.r,
            backgroundColor: Colors.red,
            child: Text("2",
                style:
                    AppTextStyles.font14SemiBold.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
