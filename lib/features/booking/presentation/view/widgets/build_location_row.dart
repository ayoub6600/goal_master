import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildLocationRow extends StatelessWidget {
  const BuildLocationRow({
    super.key,
    required this.booking,
  });
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Image.asset(
              Assets.imagesPngImageLocation,
              fit: BoxFit.cover,
            ),
            WidthSpace(10.w),
            Text(
              booking.address,
              style: AppTextStyles.font16Medium.copyWith(
                color: AppColors.fontColor,
              ),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () async {
            final double? lat = double.tryParse(booking.latitude ?? '');
            final double? lng = double.tryParse(booking.longitude ?? '');

            if (lat != null && lng != null) {
              final Uri googleMapsUri = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query=$lat,$lng");

              if (await canLaunchUrl(googleMapsUri)) {
                await launchUrl(googleMapsUri);
              } else {
                // fallback to Apple Maps for iOS
                final Uri appleMapsUri =
                    Uri.parse("https://maps.apple.com/?q=$lat,$lng");
                if (await canLaunchUrl(appleMapsUri)) {
                  await launchUrl(appleMapsUri);
                } else {
                  // error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("لا يمكن فتح الخرائط")),
                  );
                }
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(width: 1.5, color: AppColors.primary),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Image.asset(
                  Assets.imagesPngImageArrow,
                  fit: BoxFit.cover,
                ),
                WidthSpace(10.w),
                Text(
                  "الاتجاهات",
                  style: AppTextStyles.font16Medium.copyWith(
                    color: AppColors.fontColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
