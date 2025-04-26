import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
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
            ProfileItem(
              title: "حذف الحساب",
              icon: Assets.imagesPngImageLogout,
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "حذف الحساب",
                            style: AppTextStyles.font16Bold,
                          ),
                          HeightSpace(16.h),
                          Text(
                            "هل أنت متأكد من حذف حسابك؟",
                            style: AppTextStyles.font14Medium.copyWith(
                              color: AppColors.fontColor,
                            ),
                          ),
                          HeightSpace(16.h),
                          // إضافة تفاصيل حول حذف الحساب أو التواصل مع الدعم
                          Center(
                            child: Text(
                              "لحذف الحساب نهائيًا، يُرجى التواصل مع دعم العملاء عبر  :+218916771600",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.font14Medium.copyWith(
                                color: AppColors.fontColor,
                              ),
                            ),
                          ),
                          HeightSpace(16.h),
                          Row(
                            children: [
                              Expanded(
                                child: ButtonApp(
                                  text: "حذف",
                                  onTap: () async {
                                    Navigator.pop(context); // Close the sheet
                                    await SharedPreferenceUtil.clear();
                                    pushReplacement(RoutesKeys.kLogin, context);
                                    SharedPreferenceUtil.putString(
                                        PrefKey.login, "true");
                                  },
                                ),
                              ),
                              WidthSpace(16.w),
                              Expanded(
                                child: ButtonApp(
                                  textColor: Colors.white,
                                  backGround: Colors.red,
                                  text: "إلغاء",
                                  onTap: () {
                                    Navigator.pop(context); // Close the sheet
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
