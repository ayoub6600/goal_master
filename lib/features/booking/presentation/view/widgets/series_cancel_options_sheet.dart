import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/presentation/manager/series_details_cubit/series_details_cubit.dart';

/// The cancellation choices for a recurring booking, named explicitly.
///
/// Deliberately not a single "إلغاء الحجز الشهري" button: that one label
/// could mean this Thursday, every Thursday left, or the whole arrangement,
/// and the three are not recoverable from each other. Each option says exactly
/// which dates it removes before anything happens.
Future<void> showSeriesCancelOptions(
  BuildContext context, {
  required BookingSeries series,
  SeriesOccurrence? occurrence,
}) {
  final cubit = context.read<SeriesDetailsCubit>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _CancelOptionsContent(series: series, occurrence: occurrence),
    ),
  );
}

class _CancelOptionsContent extends StatelessWidget {
  const _CancelOptionsContent({required this.series, this.occurrence});

  final BookingSeries series;
  final SeriesOccurrence? occurrence;

  @override
  Widget build(BuildContext context) {
    final upcoming =
        series.occurrences.where((o) => o.canCancel).toList(growable: false);

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
          Text(
            "ماذا تريد أن تلغي؟",
            style: AppTextStyles.font18Bold.copyWith(color: AppColors.darkBlue),
          ),
          HeightSpace(16.h),

          // 1. This date only — offered when the sheet was opened from one.
          if (occurrence != null && occurrence!.canCancel)
            _option(
              context: context,
              icon: Icons.event_busy,
              title: "إلغاء هذا الموعد فقط",
              subtitle:
                  "${formatArabicDate(occurrence!.date)} — تبقى بقية المواعيد كما هي",
              onTap: () {
                Navigator.of(context).pop();
                context
                    .read<SeriesDetailsCubit>()
                    .cancelOccurrence(occurrence!.bookingId);
              },
            ),

          // 2. Everything still upcoming. Also the honest form of "cancel the
          //    whole thing" once a session has been played — the past is kept.
          if (upcoming.isNotEmpty) ...[
            HeightSpace(10.h),
            _option(
              context: context,
              icon: Icons.event_repeat,
              title: series.canCancelAll
                  ? "إلغاء الحجز الشهري بالكامل"
                  : "إلغاء كل المواعيد القادمة",
              subtitle: series.canCancelAll
                  ? "إلغاء المواعيد الأربعة — لم تبدأ السلسلة بعد"
                  : "${upcoming.length} مواعيد قادمة — المواعيد السابقة تبقى كما هي",
              isDestructive: true,
              onTap: () => _confirmCancelAll(context, upcoming),
            ),
          ],

          HeightSpace(16.h),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "تراجع",
                style: AppTextStyles.font14Bold
                    .copyWith(color: AppColors.mainGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A second step before the irreversible one, listing the exact dates that
  /// disappear.
  Future<void> _confirmCancelAll(
    BuildContext context,
    List<SeriesOccurrence> upcoming,
  ) async {
    final cubit = context.read<SeriesDetailsCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          series.canCancelAll
              ? "إلغاء الحجز الشهري؟"
              : "إلغاء المواعيد القادمة؟",
          style: AppTextStyles.font16Bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "سيتم إلغاء المواعيد التالية:",
              style: AppTextStyles.font14Regular
                  .copyWith(color: AppColors.mainGrey),
            ),
            HeightSpace(8.h),
            ...upcoming.map(
              (o) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  "• ${formatArabicDate(o.date)}",
                  style: AppTextStyles.font14Bold
                      .copyWith(color: AppColors.darkBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text("تراجع", style: AppTextStyles.font14Bold),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              "تأكيد الإلغاء",
              style:
                  AppTextStyles.font14Bold.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (confirmed == true) {
      cubit.cancelFuture(series.seriesId);
    }
  }

  Widget _option({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.errorRed : AppColors.darkBlue;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.lightWhite3,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.colorcommingItems),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.sp),
            WidthSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.font14Bold.copyWith(color: color)),
                  HeightSpace(2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.font12Regular
                        .copyWith(color: AppColors.mainGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
