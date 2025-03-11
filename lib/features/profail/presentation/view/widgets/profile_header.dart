import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Color(0xffDFF5E1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Assets.imagesPngImageProfailIcon,
          ),
          WidthSpace(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "محمد علي",
                  style: AppTextStyles.font16SemiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                HeightSpace(8.h),
                Text(
                  "1245758899",
                  style: AppTextStyles.font16SemiBold
                      .copyWith(color: Color(0xff6D7580)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
