import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/timeslot.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';

/// Picking a different hour without leaving the checkout.
///
/// The quick checkout starts from a slot that was already chosen, so it has no
/// earlier step to send the customer back to. Rather than reset the screen —
/// which is what left it half-empty — the hour is changed in place and
/// everything else about the booking stays exactly as it was.
///
/// Availability comes from the same `list/timeslot` endpoint the wizard uses;
/// nothing here decides what is free.
Future<TimeslotModel?> showChangeTimeSheet(
  BuildContext context, {
  required int branchId,
  required int serviceId,
  required String currentStartTime,
}) {
  final calendarCubit = context.read<CalendarCubit>();

  calendarCubit.listTimeslot(
    branchId: branchId,
    serviceId: serviceId,
  );

  return showModalBottomSheet<TimeslotModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: calendarCubit,
      child: _ChangeTimeContent(currentStartTime: currentStartTime),
    ),
  );
}

class _ChangeTimeContent extends StatelessWidget {
  const _ChangeTimeContent({required this.currentStartTime});

  final String currentStartTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Text("اختر وقتًا آخر", style: AppTextStyles.font18Bold),
            HeightSpace(6.h),
            Text(
              "سنحافظ على الحجز الشهري ونحدّث المواعيد الأربعة حسب الوقت الجديد.",
              style: AppTextStyles.font12Regular
                  .copyWith(color: AppColors.mainGrey),
            ),
            HeightSpace(16.h),
            Flexible(child: _slots(context)),
          ],
        ),
      ),
    );
  }

  Widget _slots(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        if (state is TimeLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Same shape the wizard's TimeSlotSection reads.
        final slots = state is TimeSuccess
            ? state.time.cast<TimeslotModel>()
            : const <TimeslotModel>[];

        if (slots.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: Center(
              child: Text(
                "لا توجد أوقات متاحة في هذا اليوم.",
                style: AppTextStyles.font14Regular
                    .copyWith(color: AppColors.mainGrey),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: slots.length,
          separatorBuilder: (_, __) => HeightSpace(8.h),
          itemBuilder: (context, i) => _slotTile(context, slots[i]),
        );
      },
    );
  }

  Widget _slotTile(BuildContext context, TimeslotModel slot) {
    final isCurrent = slot.startTime == currentStartTime;
    // isAvailable is an int flag in this API: 0 means taken.
    final available = slot.isAvailable != 0;
    // The hour that produced the clash is shown but not offered again.
    final enabled = available && !isCurrent;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: enabled ? () => Navigator.of(context).pop(slot) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.lightWhite3,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: enabled
                ? AppColors.successGreen.withOpacity(0.5)
                : AppColors.colorcommingItems,
          ),
        ),
        child: Row(
          children: [
            Icon(
              enabled ? Icons.schedule : Icons.block,
              size: 20.sp,
              color: enabled ? AppColors.successGreen : AppColors.lightGrey,
            ),
            WidthSpace(10.w),
            Expanded(
              child: Text(
                "${slot.startTime ?? ''} - ${slot.endTime ?? ''}",
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: AppTextStyles.font14Bold.copyWith(
                  color: enabled ? AppColors.darkBlue : AppColors.lightGrey,
                ),
              ),
            ),
            if (isCurrent)
              Text(
                "الوقت الحالي",
                style: AppTextStyles.font12Regular
                    .copyWith(color: AppColors.lightGrey),
              )
            else if (!available)
              Text(
                "محجوز",
                style: AppTextStyles.font12Bold
                    .copyWith(color: AppColors.errorRed),
              ),
          ],
        ),
      ),
    );
  }
}
