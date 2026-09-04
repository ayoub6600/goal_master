import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/presentation/manager/monthly_booking_cubit/monthly_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/replace_occurrence_sheet.dart';

/// The four dates a recurring booking would take, each marked available or
/// taken — shown before the customer confirms anything, so a clash is never a
/// surprise at the end of checkout.
class MonthlyDatesPreview extends StatelessWidget {
  const MonthlyDatesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyBookingCubit, MonthlyBookingState>(
      builder: (context, state) {
        if (state.isLoadingPreview) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null) {
          return _notice(
            icon: Icons.error_outline,
            color: AppColors.errorRed,
            text: state.error!,
          );
        }

        final preview = state.preview;
        if (preview == null) return const SizedBox.shrink();

        return Container(
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
                // e.g. "كل خميس الساعة 8:00 مساءً"
                "كل ${preview.dayName} الساعة ${formatArabicTime(preview.startTime)}",
                style: AppTextStyles.font14Bold.copyWith(
                  color: AppColors.darkBlue,
                ),
              ),
              HeightSpace(10.h),
              // Each week, plus the "move this one" action on any the
              // recurrence cannot have.
              ...preview.dates.expand((d) => [
                    _dateRow(context, d, state),
                    if (!d.available && d.canReplace)
                      _replaceAction(context, d),
                  ]),
              if (preview.needsApproval) ...[
                HeightSpace(4.h),
                _notice(
                  icon: Icons.event_repeat,
                  color: AppColors.mainBlue,
                  // The count is the reassurance that matters when a date is
                  // being dropped — say it before they commit, not after.
                  text: preview.summary.isNotEmpty
                      ? preview.summary
                      : "سيتم تخطي الموعد المحجوز، وستحصل على "
                          "${preview.targetOccurrenceCount} حجوزات فعلية.",
                ),
                _notice(
                  icon: Icons.touch_app_outlined,
                  color: AppColors.mainGrey,
                  text: "سيُطلب تأكيدك قبل إتمام الحجز.",
                ),
              ] else if (preview.isBlocked) ...[
                HeightSpace(4.h),
                _notice(
                  icon: Icons.info_outline,
                  color: AppColors.errorRed,
                  text: preview.summary.isNotEmpty
                      ? preview.summary
                      : "لا يمكن إنشاء الحجز الشهري بهذه المواعيد. "
                          "جرّب يومًا أو ساعة أخرى.",
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// One candidate week. A skipped week is shown struck through rather than
  /// hidden: the customer is agreeing to lose that date, so they should see
  /// it. The extension week is marked, so the series running a week longer is
  /// never a surprise later.
  Widget _dateRow(
      BuildContext context, PreviewDate d, MonthlyBookingState state) {
    // The backend already returned the FINAL schedule: a moved week arrives
    // at its real date and time with is_replacement set, and the extension
    // week it no longer needs is simply not in the list.
    if (d.isReplacement) {
      return _replacedRow(context, d);
    }

    final (icon, color, label) = switch (d) {
      PreviewDate(isSkipped: true) => (
          Icons.remove_circle_outline,
          AppColors.mainGrey,
          "محجوز من قبل شخص آخر"
        ),
      PreviewDate(available: false) => (
          Icons.cancel,
          AppColors.errorRed,
          "محجوز"
        ),
      PreviewDate(isExtension: true) => (
          Icons.add_circle,
          AppColors.successGreen,
          "موعد بديل"
        ),
      _ => (Icons.check_circle, AppColors.successGreen, ""),
    };

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          WidthSpace(8.w),
          Expanded(
            // Each line carries its own time. Date alone would imply every
            // session is at the series hour, which stops being true the
            // moment one week moves.
            child: Text(
              d.startTime.isEmpty
                  ? formatArabicDate(d.date)
                  : '${formatArabicDate(d.date)} — ${formatArabicTime(d.startTime)}',
              style: AppTextStyles.font14Regular.copyWith(
                color: d.available ? AppColors.darkBlue : color,
                decoration: d.isSkipped ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: AppTextStyles.font12Bold.copyWith(color: color),
            ),
        ],
      ),
    );
  }

  /// A blocked week the customer can move rather than lose.
  Widget _replaceAction(BuildContext context, PreviewDate d) {
    final options = d.replacementOptions;
    if (options == null || !options.hasAny) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: 26.w, bottom: 8.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          icon: Icon(Icons.swap_horiz, size: 16.sp, color: AppColors.primary),
          label: Text(
            'تغيير هذا الموعد',
            style: AppTextStyles.font12Bold.copyWith(color: AppColors.primary),
          ),
          onPressed: () async {
            final cubit = context.read<MonthlyBookingCubit>();

            final chosen = await ReplaceOccurrenceSheet.show(
              context,
              originalDate: d.date,
              originalTimeLabel: formatArabicTime(
                context.read<MonthlyBookingCubit>().state.preview?.startTime ??
                    '',
              ),
              options: options,
            );

            if (chosen != null) {
              cubit.chooseReplacement(d.date, chosen);
            }
          },
        ),
      ),
    );
  }

  /// The week as it will actually be booked, badged so the difference from
  /// the recurring pattern is obvious at a glance.
  Widget _replacedRow(BuildContext context, PreviewDate d) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9.r),
        border:
            Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz, size: 18.sp, color: AppColors.successGreen),
          WidthSpace(8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatArabicDate(d.date)} — ${formatArabicTime(d.startTime)}',
                  style: AppTextStyles.font14Regular
                      .copyWith(color: AppColors.darkBlue),
                ),
                if (d.originalDate.isNotEmpty)
                  Text(
                    'بديل عن ${formatArabicDate(d.originalDate)}',
                    style: AppTextStyles.font12Regular
                        .copyWith(color: AppColors.mainGrey),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text('موعد بديل',
                style: AppTextStyles.font12Bold
                    .copyWith(color: AppColors.successGreen)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: 16.sp, color: AppColors.mainGrey),
            onPressed: () => context
                .read<MonthlyBookingCubit>()
                .clearReplacement(d.originalDate),
          ),
        ],
      ),
    );
  }

  Widget _notice({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: color),
          WidthSpace(6.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.font12Regular.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
