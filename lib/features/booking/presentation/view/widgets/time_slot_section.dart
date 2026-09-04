import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class TimeSlotSection extends StatelessWidget {
  final PageController controller;

  const TimeSlotSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        if (state is TimeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is TimeFailure) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.red,
              ),
            ),
          );
        }

        if (state is TimeSuccess) {
          final times = state.time;

          if (times.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أوقات متاحة لهذا اليوم',
                style: AppTextStyles.font16Bold,
                textAlign: TextAlign.center,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 8.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StepTitle(
                  title: 'وقت الحجز',
                  description: 'قم باختيار الوقت المناسب للحجز الذي تريده',
                ),

                HeightSpace(16.h),

                /*
                 * مهم:
                 *
                 * لا نضع عبارة "بعد منتصف الليل" هنا فوق القائمة كلها.
                 *
                 * بدل ذلك، نضيفها داخل القائمة بالضبط عند الانتقال
                 * من المواعيد المسائية إلى أول موعد بعد منتصف الليل.
                 *
                 * كذلك استخدمنا Expanded + SingleChildScrollView
                 * لمنع Bottom Overflow.
                 */
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 0,
                          runSpacing: 0,
                          children: _buildTimeSlots(
                            context: context,
                            state: state,
                            times: times,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<Widget> _buildTimeSlots({
    required BuildContext context,
    required TimeSuccess state,
    required List<dynamic> times,
  }) {
    final widgets = <Widget>[];

    for (int index = 0; index < times.length; index++) {
      final slot = times[index];

      /*
       * نعرض separator فقط عند أول Slot بعد منتصف الليل.
       *
       * مثال:
       *
       * 10 PM - 11 PM
       * 11 PM - 12 AM
       *
       * --------
       * بعد منتصف الليل — الاثنين 31 أغسطس
       * --------
       *
       * 12 AM - 1 AM
       * 1 AM - 2 AM
       */
      final bool isFirstAfterMidnight =
          slot.afterMidnight == true &&
          (index == 0 || times[index - 1].afterMidnight != true);

      if (isFirstAfterMidnight) {
        widgets.add(
          SizedBox(
            width: double.infinity,
            child: _AfterMidnightDivider(
              date: slot.date,
            ),
          ),
        );
      }

      widgets.add(
        _TimeSlotButton(
          slot: slot,
          isSelected: _isSlotSelected(
            state: state,
            slot: slot,
          ),
          onTap: () {
            _selectSlot(
              context: context,
              slot: slot,
            );
          },
        ),
      );
    }

    return widgets;
  }

  bool _isSlotSelected({
    required TimeSuccess state,
    required dynamic slot,
  }) {
    /*
     * إذا كان selectedTime عبارة عن DateTime،
     * نقارن الساعة فقط بالطريقة القديمة حتى لا نكسر Cubit الحالي.
     *
     * ويمكن لاحقًا جعل الاختيار يعتمد على startAt كاملًا.
     */
    final selected = state.selectedTime;

    if (selected == null) {
      return false;
    }

    try {
      if (selected is DateTime) {
        final selectedHour =
            '${selected.hour.toString().padLeft(2, '0')}:'
            '${selected.minute.toString().padLeft(2, '0')}';

        final slotHour = slot.startTime
            .toString()
            .substring(0, 5);

        return selectedHour == slotHour;
      }
    } catch (_) {
      // Backwards-compatible fallback.
    }

    return selected.toString() == slot.startTime.toString();
  }

  void _selectSlot({
    required BuildContext context,
    required dynamic slot,
  }) {
    if (slot.isAvailable == 0) {
      return;
    }

    /*
     * مصدر الحقيقة الآن هو السيرفر.
     *
     * لا نعمل:
     * selectedDate + startTime
     *
     * ولا:
     * addDay()
     *
     * إذا السيرفر أعطانا startAt / endAt نستخدمهما كما هما.
     */
    final start = _parseServerDateTime(
      primary: slot.startAt,
      date: slot.date,
      time: slot.startTime,
    );

    final end = _parseServerDateTime(
      primary: slot.endAt,
      date: slot.date,
      time: slot.endTime,
    );

    /*
     * employeeId ما زال مطلوبًا داخليًا لأن الـbackend
     * ما زال يحتفظ بالـtime bands.
     *
     * الزبون لا يحتاج أن يختاره بنفسه.
     */
    if (slot.employeeId != null) {
      context.read<PageViewCubit>().setEmployeeId(
            slot.employeeId!,
          );
    }

    context.read<CalendarCubit>().selectTime(start);
    context.read<CalendarCubit>().selectTimeEnd(end);

    context.read<PageViewCubit>().nextPage();

    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  DateTime _parseServerDateTime({
    required dynamic primary,
    required dynamic date,
    required dynamic time,
  }) {
    /*
     * New server contract:
     * startAt/endAt are authoritative.
     */
    if (primary != null &&
        primary.toString().trim().isNotEmpty) {
      final parsed = DateTime.tryParse(
        primary.toString(),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    /*
     * Legacy compatibility only.
     *
     * المفروض مع الـbackend الجديد ألا نصل لهذا المسار
     * في الـunified availability.
     */
    final fallback =
        '${date.toString()} ${time.toString()}';

    final parsed = DateTime.tryParse(fallback);

    if (parsed == null) {
      throw FormatException(
        'Invalid booking slot datetime: $fallback',
      );
    }

    return parsed;
  }
}

/// One bookable hour.
///
/// The time reads as one Arabic phrase — «5:00 – 6:00 مساءً» — rather than two
/// English stamps with a dash between them. The period is written once when
/// both ends share it, and both are named when the slot crosses into the small
/// hours, which is exactly where a customer needs to look twice.
class _TimeSlotButton extends StatelessWidget {
  final dynamic slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeSlotButton({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool available = slot.isAvailable != 0;

    final Color border = !available
        ? AppColors.grey.withValues(alpha: 0.35)
        : isSelected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.35);

    final Color background = !available
        ? AppColors.grey.withValues(alpha: 0.07)
        : isSelected
            ? AppColors.primary
            : Colors.white;

    final Color foreground = !available
        ? AppColors.grey
        : isSelected
            ? Colors.white
            : const Color(0xff204523);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: available ? onTap : null,
          borderRadius: BorderRadius.circular(14.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: border,
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  available
                      ? (isSelected
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded)
                      : Icons.lock_outline_rounded,
                  size: 20.sp,
                  color: foreground,
                ),
                WidthSpace(10.w),
                Expanded(
                  child: Text(
                    formatArabicTimeRange(slot.startTime, slot.endTime),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppTextStyles.font16Bold.copyWith(
                      color: foreground,
                      // A booked hour is struck through rather than merely
                      // faded: greyed-out text alone reads as "loading".
                      decoration:
                          available ? null : TextDecoration.lineThrough,
                      decorationColor: AppColors.grey,
                    ),
                  ),
                ),
                if (!available)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Text(
                      'محجوز',
                      style: AppTextStyles.font12Medium
                          .copyWith(color: AppColors.grey),
                    ),
                  )
                else
                  SizedBox(width: 20.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AfterMidnightDivider extends StatelessWidget {
  final String? date;

  const _AfterMidnightDivider({
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Names the real calendar day. The customer thinks of these hours as part
    // of tonight; the booking is on tomorrow's date, and hiding that would be
    // the same quiet dishonesty as the old band picker.
    final label = date == null
        ? 'بعد منتصف الليل'
        : 'بعد منتصف الليل — ${_arabicDate(date!)}';

    return Padding(
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: 8.h,
        left: 8.w,
        right: 8.w,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1.h,
              thickness: 1,
              color: AppColors.grey.withValues(
                alpha: 0.35,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(99.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.nightlight_round,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  WidthSpace(6.w),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font12Medium
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Divider(
              height: 1.h,
              thickness: 1,
              color: AppColors.grey.withValues(
                alpha: 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _arabicDate(String iso) {
    final parsed = DateTime.tryParse(iso);

    if (parsed == null) {
      return iso;
    }

    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${days[parsed.weekday - 1]} '
        '${parsed.day} '
        '${months[parsed.month - 1]}';
  }
}