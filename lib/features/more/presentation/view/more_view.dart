import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';

import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/more/presentation/view/widgets/information_to_app_view.dart';
import 'package:goal_master/features/more/presentation/view/widgets/term_and_condition_view.dart';
import 'package:goal_master/features/profail/presentation/view/widgets/profile_item.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "المزيد",
      allowBack: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            HeightSpace(20.h),
            ProfileItem(
              title: "معلومات عن التطبيق",
              icon: Assets.imagesPngImageDanger,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return InformationToAppView();
                }));
                // push(RoutesKeys.kUpdateProfile, context);
              },
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(8.h),
            ProfileItem(
              title: "الشروط والاحكام",
              icon: Assets.imagesPngImageReceiptEdit,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TermAndConditionView();
                }));

                // push(RoutesKeys.kUpdateProfile, context);
              },
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(8.h),
            ProfileItem(
              title: "مشاركة التطبيق",
              icon: Assets.imagesPngImageSend2,
              onTap: () {
                // push(RoutesKeys.kUpdateProfile, context);
              },
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(8.h),
          ],
        ),
      ),
    );
  }
}
