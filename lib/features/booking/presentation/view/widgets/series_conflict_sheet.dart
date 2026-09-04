import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';

/// Why a recurring booking was refused — every clashing week, not just the
/// first one.
///
/// The backend rejects the series as a whole rather than booking the weeks
/// that happen to be free, so the customer is told the full reason at once
/// and can pick a different day or hour in one step instead of discovering
/// the clashes one at a time.
Future<void> showSeriesConflictSheet(
  BuildContext context, {
  required String message,
  required List<ConflictedDate> conflicts,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SeriesConflictContent(
      message: message,
      conflicts: conflicts,
    ),
  );
}

class _SeriesConflictContent extends StatelessWidget {
  const _SeriesConflictContent({
    required this.message,
    required this.conflicts,
  });

  final String message;
  final List<ConflictedDate> conflicts;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.event_busy, color: AppColors.errorRed, size: 26.sp),
              WidthSpace(10.w),
              Expanded(
                child: Text(
                  "لا يمكن إنشاء الحجز الشهري",
                  style: AppTextStyles.font18Bold
                      .copyWith(color: AppColors.errorRed),
                ),
              ),
            ],
          ),
          HeightSpace(12.h),
          Text(
            conflicts.isEmpty ? message : "المواعيد التالية محجوزة:",
            style: AppTextStyles.font14Regular
                .copyWith(color: AppColors.mainGrey),
          ),
          HeightSpace(12.h),
          ...conflicts.map(
            (c) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.close, size: 18.sp, color: AppColors.errorRed),
                  WidthSpace(8.w),
                  Expanded(
                    child: Text(
                      "${formatArabicDate(c.date)} — ${formatArabicTime(c.startTime)}",
                      style: AppTextStyles.font14Bold
                          .copyWith(color: AppColors.darkBlue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          HeightSpace(8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.lightWhite3,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              // Says plainly that nothing was booked, so the customer does not
              // go looking for a half-created series.
              "لم يتم حجز أي موعد. يمكنك اختيار يوم أو ساعة أخرى، "
              "أو إنشاء حجز عادي بدلاً من ذلك.",
              style: AppTextStyles.font12Regular
                  .copyWith(color: AppColors.mainGrey),
            ),
          ),
          HeightSpace(20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "حسنًا",
                style: AppTextStyles.font16Bold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
