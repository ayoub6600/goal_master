import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/profail/presentation/view/update_profile_view.dart';
import 'package:goal_master/features/profail/presentation/view/widgets/profile_header.dart';
import 'package:goal_master/features/profail/presentation/view/widgets/profile_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "حسابي",
      allowBack: false,
      child: Column(
        children: [
          ProfileHeader(),
          HeightSpace(16.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                //  spacing: 16.h,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        Assets.imagesPngImageSetting2,
                        fit: BoxFit.cover,
                      ),
                      WidthSpace(16.w),
                      Text(
                        "اعدادات عامة",
                        style: AppTextStyles.font16Bold.copyWith(
                          color: AppColors.fontColor,
                        ),
                      ),
                    ],
                  ),
                  HeightSpace(8.h),
                  ProfileItem(
                    title: "تغيير معلوماتك الشخصية",
                    icon: Assets.imagesPngImageMagicpen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProfileView()),
                      );
                    },
                  ),
                  Container(
                    width: double.infinity,
                    color: Color(0xffDADEE3),
                    height: 1.h,
                  ),
                  HeightSpace(8.h),
                  ProfileItem(
                    title: "تفعيل الاشعارات",
                    icon: Assets.imagesPngImageNotification,
                    onTap: () {},
                  ),
                  Container(
                    width: double.infinity,
                    color: Color(0xffDADEE3),
                    height: 1.h,
                  ),
                  HeightSpace(8.h),
                  ProfileItem(
                    title: "تغيير كلمة المرور",
                    icon: Assets.imagesPngImageKey,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateProfileView()),
                      );
                    },
                  ),
                  Container(
                    width: double.infinity,
                    color: Color(0xffDADEE3),
                    height: 1.h,
                  ),
                  HeightSpace(8.h),
                  ProfileItem(
                    title: "اتصل بنا",
                    icon: Assets.imagesPngImageCallCalling,
                    onTap: () {},
                  ),
                  Container(
                    width: double.infinity,
                    color: Color(0xffDADEE3),
                    height: 1.h,
                  ),
                  HeightSpace(8.h),
                  ProfileItem(
                    title: "خروج",
                    icon: Assets.imagesPngImageLogout,
                    onTap: () {},
                    child: SizedBox(),
                  ),
                  Container(
                    width: double.infinity,
                    color: Color(0xffDADEE3),
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
