import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/profail/presentation/view/widgets/profile_item.dart';

class ContactUsBody extends StatelessWidget {
  const ContactUsBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "اتصل بنا",
      allowBack: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeightSpace(16.h),
            Text(
              "تواصل معنا عبر",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(16.h),
            ProfileItem(
              title: "+218916771600",
              icon: Assets.imagesPngImageCallCalling,
              onTap: () {},
              child: SizedBox(),
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(16.h),
            ProfileItem(
              title: "support@goalmasters.online",
              icon: Assets.imagesPngImageSms,
              onTap: () {},
              child: SizedBox(),
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(16.h),
            ProfileItem(
              title: "www.goalmasters.online",
              icon: Assets.imagesPngImageGlobalRefresh,
              onTap: () {},
              child: SizedBox(),
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(16.h),
            ProfileItem(
              title: "ليبيا - مدينة مصراتة",
              icon: Assets.imagesPngImageLocation,
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
    );
  }
}
