import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_details_section.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_header_image.dart';

class BookingItemsDetails extends StatelessWidget {
  const BookingItemsDetails({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BuildHeaderImage(),
              BuildDetailsSection(
                booking: booking,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBookingButton extends StatelessWidget {
  const CustomBookingButton({super.key, required this.text, this.onTap});
  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 26.h),
      decoration: BoxDecoration(
        color: Color(0xffF4F6F9),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000), // #00000040 in ARGB format
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ButtonApp(
              text: text,
              textColor: Colors.white,
              backGround: AppColors.primary,
              onTap: onTap,
            ),
          ),
          WidthSpace(2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "السعر ",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: AppColors.fontColor,
                  ),
                ),
                HeightSpace(8.h),
                Text(
                  "دينار60.00",
                  style: AppTextStyles.font16Bold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
