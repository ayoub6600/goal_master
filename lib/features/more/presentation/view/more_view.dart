import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/more/presentation/view/widgets/information_to_app_view.dart';
import 'package:goal_master/features/more/presentation/view/widgets/term_and_condition_view.dart';
import 'package:goal_master/features/profail/presentation/view/widgets/profile_item.dart';
import 'package:share_plus/share_plus.dart';

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
              },
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(8.h),
            LayoutBuilder(
              builder: (context, constraints) => ProfileItem(
                title: "مشاركة التطبيق",
                icon: Assets.imagesPngImageSend2,
                onTap: () {
                  final RenderBox? box =
                      context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final offset = box.localToGlobal(Offset.zero);
                    final size = box.size;

                    print("Offset: $offset, Size: $size");

                    if (size.width > 0 && size.height > 0) {
                      Share.share(
                        'جرّب تطبيق Goal Master الآن وحقق أهدافك! 🏆📲\n'
                        'على Android:\nhttps://play.google.com/store/apps/details?id=com.ayoub.goalmaster\n'
                        'على iOS:\nhttps://apps.apple.com/app/id6744951483\n',
                        sharePositionOrigin: offset & size,
                      );
                    }
                  }
                },
              ),
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
