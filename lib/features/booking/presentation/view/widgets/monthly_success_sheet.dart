import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';

/// One confirmation for the whole recurring booking.
///
/// Four bookings were created, but the customer made one decision — so they
/// see one message listing all four dates, never four success popups in a row.
Future<void> showMonthlySuccessSheet(
  BuildContext context, {
  required BookingSeries series,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _MonthlySuccessContent(series: series),
  );
}

class _MonthlySuccessContent extends StatelessWidget {
  const _MonthlySuccessContent({required this.series});

  final BookingSeries series;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          // Wording comes from the SERIES STATUS, never from the fact that
          // the request succeeded. A pay-on-arrival booking that still needs
          // the venue's approval is a request, not a confirmation — telling
          // the customer otherwise sends them to a pitch nobody promised them.
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: (_awaitingVenue ? _pendingAmber : AppColors.successGreen)
                  .withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _awaitingVenue
                  ? Icons.hourglass_top_rounded
                  : Icons.check_rounded,
              color: _awaitingVenue ? _pendingAmber : AppColors.successGreen,
              size: 34.sp,
            ),
          ),
          HeightSpace(14.h),
          Text(
            _awaitingVenue ? "تم طلب حجزك الشهري" : "تم تأكيد حجزك الشهري",
            style: AppTextStyles.font20Bold.copyWith(color: AppColors.darkBlue),
            textAlign: TextAlign.center,
          ),
          HeightSpace(8.h),
          Text(
            _awaitingVenue
                ? "تم استلام طلبك بنجاح وسيتم مراجعته من قبل إدارة الملعب."
                : "كل ${series.dayName} الساعة ${formatArabicTime(series.startTime)}",
            style:
                AppTextStyles.font16Medium.copyWith(color: AppColors.mainGrey),
            textAlign: TextAlign.center,
          ),
          if (_awaitingVenue) ...[
            HeightSpace(10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _pendingAmber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                "الحالة: في انتظار قبول الحجز",
                style: AppTextStyles.font14Bold.copyWith(color: _pendingAmber),
              ),
            ),
          ],
          HeightSpace(16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.lightWhite3,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${series.occurrenceCount} مواعيد",
                  style: AppTextStyles.font14Bold
                      .copyWith(color: AppColors.darkBlue),
                ),
                HeightSpace(10.h),
                // Every session listed with its OWN date and time. A single
                // "every Monday at 5" line stops being true the moment one
                // week is moved.
                ...series.occurrences.map(_occurrenceLine),
              ],
            ),
          ),
          if (series.branch.isNotEmpty) ...[
            HeightSpace(10.h),
            Text(
              series.branch,
              style: AppTextStyles.font14Regular
                  .copyWith(color: AppColors.mainGrey),
            ),
          ],
          HeightSpace(20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "تم",
                style: AppTextStyles.font16Bold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The amber used for "waiting on the venue" — deliberately not green,
  /// which would read as confirmed.
  static const _pendingAmber = Color(0xFFB26A00);

  /// True when the venue has still to answer.
  ///
  /// Read from the occurrences' real status (Processing = 1), not from the
  /// payment method and not from the HTTP result. A successful API call means
  /// "request created", which is not the same as "booking approved".
  bool get _awaitingVenue =>
      series.occurrences.isNotEmpty &&
      series.occurrences.every((o) => o.isPending);

  /// One session: its own date, its own time, badged if it was moved.
  Widget _occurrenceLine(SeriesOccurrence o) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            o.isReplacement ? Icons.swap_horiz : Icons.event_available,
            size: 16.sp,
            color:
                o.isReplacement ? AppColors.successGreen : AppColors.mainGrey,
          ),
          WidthSpace(7.w),
          Expanded(
            child: Text(
              '${formatArabicDate(o.date)} — ${formatArabicTime(o.startTime)}',
              style: AppTextStyles.font14Regular
                  .copyWith(color: AppColors.darkBlue),
            ),
          ),
          if (o.isReplacement)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text('موعد بديل',
                  style: AppTextStyles.font12Bold
                      .copyWith(color: AppColors.successGreen)),
            )
          else if (o.isPending)
            Text('في انتظار القبول',
                style: AppTextStyles.font12Bold.copyWith(color: _pendingAmber)),
        ],
      ),
    );
  }
}
