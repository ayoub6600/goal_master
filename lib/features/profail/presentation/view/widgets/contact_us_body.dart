import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/profail/presentation/view/widgets/profile_item.dart';
import 'package:url_launcher/url_launcher.dart';

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
              onTap: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: '+218916776600');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  // مثلاً تعرض Toast أو رسالة
                  print('لا يمكن إجراء الاتصال');
                }
              },
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
              onTap: () => _sendEmail("support@goalmasters.online"),
              child: SizedBox(),
            ),
            Container(
              width: double.infinity,
              color: Color(0xffDADEE3),
              height: 1.h,
            ),
            HeightSpace(16.h),
            ProfileItem(
              title: "web.goalmasters.online",
              icon: Assets.imagesPngImageGlobalRefresh,
              onTap: () => _openWebsite("https://web.goalmasters.online"),
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

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=دعم GoalMaster&body='),
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  Future<void> _openWebsite(String url) async {
    try {
      // Ensure the URL starts with a valid scheme
      final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');

      // Log the URL to check if it's formatted correctly
      print('Attempting to open URL: $uri');

      // Attempt to launch the URL
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        // If the URL can't be launched, show an error
        throw 'Could not launch $uri';
      }
    } catch (e) {
      // Log the error for debugging
      print('Error opening website: $e');
      // Optionally, show a Toast or Snackbar for better UX
      // For example:
      // showToast('Could not open website.');
    }
  }
}
