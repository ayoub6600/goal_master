import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/format_to_hour.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/status_container.dart';

class ItemsNotification extends StatelessWidget {
  const ItemsNotification({
    super.key,
    required this.booking,
  });
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        push(RoutesKeys.kBookingItemsDetails, context, extra: booking);
      },
      child: Container(
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
                    " تم تأكيد حجزك في ${booking.branch} يوم ${booking.date} ",
                    style: AppTextStyles.font14SemiBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formatToHour(booking.startTime) +
                        " - " +
                        formatToHour(booking.endTime),
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.font14SemiBold,
                  ),
                ],
              ),
            ),
            WidthSpace(12.w),
            StatusContainer(
              status: booking.status,
            ),
          ],
        ),
      ),
    );
  }
}
