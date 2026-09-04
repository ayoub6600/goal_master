import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';

/// What the customer decided about a plan that steps over a taken week.
enum SkipDecision {
  /// Book the four dates shown, skipping the taken week(s).
  skipAndContinue,

  /// Go back and pick a different day or hour.
  chooseAnotherTime,

  /// Abandon the recurring booking entirely.
  cancel,
}

/// Offers to skip a taken week and extend the series, so the customer still
/// gets four bookings instead of losing the whole thing over one clash.
///
/// The three answers are kept distinct because they lead somewhere different:
/// approving books the shown dates, "another time" returns to the picker, and
/// cancel abandons the recurring booking. Collapsing them into yes/no would
/// force the customer who just wants a different hour to start over.
///
/// Returns null if dismissed, which is treated as [SkipDecision.cancel].
Future<SkipDecision?> showSkipAndExtendSheet(
  BuildContext context, {
  required List<ConflictedDate> conflicts,
  required List<String> proposedDates,
  /// True when this is a re-approval because the dates moved since the last
  /// one. Nothing was booked either way.
  bool planChanged = false,
}) {
  return showModalBottomSheet<SkipDecision>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _SkipAndExtendContent(
      conflicts: conflicts,
      proposedDates: proposedDates,
      planChanged: planChanged,
    ),
  );
}

class _SkipAndExtendContent extends StatelessWidget {
  const _SkipAndExtendContent({
    required this.conflicts,
    required this.proposedDates,
    required this.planChanged,
  });

  final List<ConflictedDate> conflicts;
  final List<String> proposedDates;
  final bool planChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: SingleChildScrollView(
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
            if (planChanged) _changedNotice(),
            Row(
              children: [
                Icon(Icons.event_repeat,
                    color: AppColors.mainBlue, size: 26.sp),
                WidthSpace(10.w),
                Expanded(
                  child: Text(
                    "يوجد حجز مسبق",
                    style: AppTextStyles.font18Bold
                        .copyWith(color: AppColors.darkBlue),
                  ),
                ),
              ],
            ),
            HeightSpace(12.h),
            ...conflicts.map(_conflictLine),
            HeightSpace(12.h),
            Text(
              conflicts.length > 1
                  ? "هل تريد تخطي هذه الأسابيع والاستمرار حتى تحصل على 4 حجوزات؟"
                  : "هل تريد تخطي هذا الأسبوع والاستمرار حتى تحصل على 4 حجوزات؟",
              style: AppTextStyles.font14Medium
                  .copyWith(color: AppColors.mainGrey),
            ),
            if (proposedDates.isNotEmpty) ...[
              HeightSpace(14.h),
              _proposedPlan(),
            ],
            HeightSpace(20.h),
            _primary(context),
            HeightSpace(8.h),
            _secondary(
              context,
              label: "اختيار وقت آخر",
              decision: SkipDecision.chooseAnotherTime,
            ),
            HeightSpace(4.h),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(SkipDecision.cancel),
                child: Text(
                  "إلغاء",
                  style: AppTextStyles.font14Bold
                      .copyWith(color: AppColors.mainGrey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Said plainly, because "the plan changed" reads like a failure otherwise.
  Widget _changedNotice() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.mainBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        "تغيّرت المواعيد المتاحة أثناء الحجز، ولم يتم حجز أي شيء. "
        "راجع الخطة الجديدة قبل التأكيد.",
        style: AppTextStyles.font12Regular.copyWith(color: AppColors.darkBlue),
      ),
    );
  }

  Widget _conflictLine(ConflictedDate conflict) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, size: 18.sp, color: AppColors.errorRed),
          WidthSpace(8.w),
          Expanded(
            child: Text(
              "${formatArabicDate(conflict.date)}"
              "${conflict.startTime.isEmpty ? '' : ' — ${formatArabicTime(conflict.startTime)}'}",
              style:
                  AppTextStyles.font14Bold.copyWith(color: AppColors.darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  /// The reassurance that matters: still four bookings, and here they are.
  Widget _proposedPlan() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.lightWhite3,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.colorcommingItems),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ستحصل على ${proposedDates.length} حجوزات فعلية:",
            style: AppTextStyles.font14Bold
                .copyWith(color: AppColors.successGreen),
          ),
          HeightSpace(10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (var i = 0; i < proposedDates.length; i++)
                _dateChip(
                  formatArabicDate(proposedDates[i]),
                  // The last date is only reached because a week was
                  // skipped — worth pointing at so the extension isn't a
                  // surprise later.
                  isExtension: i == proposedDates.length - 1,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, {bool isExtension = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isExtension
              ? AppColors.successGreen
              : AppColors.colorcommingItems,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style:
                AppTextStyles.font12Bold.copyWith(color: AppColors.darkBlue),
          ),
          if (isExtension) ...[
            WidthSpace(4.w),
            Icon(Icons.add, size: 12.sp, color: AppColors.successGreen),
          ],
        ],
      ),
    );
  }

  Widget _primary(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 98, 181, 96),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: () =>
            Navigator.of(context).pop(SkipDecision.skipAndContinue),
        child: Text(
          "تخطي والاستمرار",
          style: AppTextStyles.font16Bold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _secondary(
    BuildContext context, {
    required String label,
    required SkipDecision decision,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.mainGrey),
          padding: EdgeInsets.symmetric(vertical: 13.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(decision),
        child: Text(
          label,
          style: AppTextStyles.font14Bold.copyWith(color: AppColors.darkBlue),
        ),
      ),
    );
  }
}
