import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/monthly_booking_cubit/monthly_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/monthly_dates_preview.dart';

/// "حجز عادي" or "حجز شهري", and what the monthly choice actually commits to.
///
/// Both options stay on screen at all times as radio buttons — only the
/// selected state changes. An option that disappears once picked leaves the
/// customer no way back, which is exactly what went wrong before.
///
/// The description says what is really being bought — the same day and hour
/// for four weeks — rather than "a month", which the system does not mean and
/// which would set the wrong expectation about the fourth date landing in the
/// following month.
class BookingTypeSelector extends StatelessWidget {
  const BookingTypeSelector({
    super.key,
    required this.branchId,
    required this.employeeId,
    required this.serviceId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.startAt,
    this.endAt,
  });

  final int branchId;
  final int employeeId;
  final int serviceId;
  final String date;
  final String startTime;
  final String endTime;

  /// Authoritative occurrence datetimes, forwarded to the preview so the
  /// recurrence anchors on the slot's real calendar date.
  final String? startAt;
  final String? endAt;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthlyBookingCubit, MonthlyBookingState>(
      builder: (context, state) {
        // Monthly booking is a feature of the venue's subscription. When the
        // branch does not have it there is nothing to choose between, so the
        // whole control disappears rather than showing a disabled option —
        // and no upgrade message either: which plan the venue holds is not
        // the customer's concern.
        if (!state.monthlyAvailable) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("نوع الحجز", style: AppTextStyles.font16Bold),
            HeightSpace(8.h),
            // Side by side, so the alternative is always visible next to the
            // current choice.
            Row(
              children: [
                Expanded(
                  child: _option(
                    context: context,
                    type: BookingType.normal,
                    selected: !state.isMonthly,
                    label: "حجز عادي",
                  ),
                ),
                WidthSpace(10.w),
                Expanded(
                  child: _option(
                    context: context,
                    type: BookingType.monthly,
                    selected: state.isMonthly,
                    label: "حجز شهري",
                  ),
                ),
              ],
            ),
            // Nothing extra for a normal booking: the ordinary checkout is
            // unchanged.
            if (state.isMonthly) ...[
              HeightSpace(10.h),
              _explanation(),
              HeightSpace(10.h),
              const MonthlyDatesPreview(),
              if (state.preview != null && state.preview!.totalAmount > 0) ...[
                HeightSpace(10.h),
                _price(state),
              ],
            ],
          ],
        );
      },
    );
  }

  /// A radio row, matching the app's existing green/RTL styling.
  Widget _option({
    required BuildContext context,
    required BookingType type,
    required bool selected,
    required String label,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () {
        final cubit = context.read<MonthlyBookingCubit>();
        cubit.selectType(type);

        // Fetched only when the customer actually asks for a recurring
        // booking — the dates, their availability, and the price are all the
        // backend's answer, so there is nothing to show until it replies.
        if (type == BookingType.monthly) {
          cubit.loadPreview(
            branchId: branchId,
            employeeId: employeeId,
            serviceId: serviceId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            startAt: startAt,
            endAt: endAt,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.successGreen.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                selected ? AppColors.successGreen : AppColors.colorcommingItems,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20.sp,
              color: selected ? AppColors.successGreen : AppColors.lightGrey,
            ),
            WidthSpace(8.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.font14Bold.copyWith(
                  color:
                      selected ? AppColors.successGreen : AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _explanation() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.mainBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.mainBlue.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.sp, color: AppColors.mainBlue),
          WidthSpace(8.w),
          Expanded(
            child: Text(
              "سيتم حجز نفس اليوم ونفس الساعة لمدة 4 مواعيد أسبوعية.",
              style: AppTextStyles.font12Regular
                  .copyWith(color: AppColors.darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  /// The total, so it is never a surprise at the moment of payment. Both
  /// figures come from the backend — the app does no arithmetic of its own.
  Widget _price(MonthlyBookingState state) {
    final preview = state.preview!;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  "${preview.targetOccurrenceCount} مواعيد × "
                  "${preview.pricePerOccurrence.toStringAsFixed(0)} د.ل",
                  style: AppTextStyles.font12Regular
                      .copyWith(color: AppColors.mainGrey),
                ),
              ),
            ],
          ),
          HeightSpace(6.h),
          Row(
            children: [
              Text("الإجمالي", style: AppTextStyles.font14Bold),
              const Spacer(),
              Text(
                "${preview.totalAmount.toStringAsFixed(0)} د.ل",
                style: AppTextStyles.font16Bold
                    .copyWith(color: AppColors.successGreen),
              ),
            ],
          ),
          if (preview.paymentNote.isNotEmpty) ...[
            HeightSpace(6.h),
            Text(
              preview.paymentNote,
              style: AppTextStyles.font12Regular
                  .copyWith(color: AppColors.mainGrey),
            ),
          ],
        ],
      ),
    );
  }
}
