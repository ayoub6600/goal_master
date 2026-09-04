import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/booking/data/model/operational_night_context.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_state.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/full_calendar_sheet.dart';

/// Picking the booking date.
///
/// Most bookings are for the next few days, so those are one tap away on a
/// horizontal strip rather than behind a month grid. The full calendar is
/// still there for anything further out — it just isn't the first thing in
/// the way.
///
/// Purely presentational: which days are bookable is still the backend's
/// answer, checked when the slot is chosen. Nothing here decides availability.
class BookingDateSelector extends StatefulWidget {
  const BookingDateSelector({
    super.key,
    this.onDatePicked,
    this.branchId,
    this.serviceId,
  });

  /// Called after a date is chosen, so the wizard can advance.
  final VoidCallback? onDatePicked;

  /// Needed to ask the server whether the night in progress is still bookable.
  /// Omitted where that question does not apply.
  final int? branchId;
  final int? serviceId;

  @override
  State<BookingDateSelector> createState() => _BookingDateSelectorState();
}

class _BookingDateSelectorState extends State<BookingDateSelector> {
  final ScrollController _strip = ScrollController();

  /// How far ahead the quick strip runs before the calendar takes over.
  static const _stripDays = 14;

  /// The server's answer about the night already under way.
  ///
  /// Starts as "nothing on offer" so the strip renders normally while the
  /// question is still in flight, and stays that way if it fails — the card is
  /// an extra route to a night, never the only one.
  OperationalNightContext _previousNight = OperationalNightContext.none;

  @override
  void initState() {
    super.initState();
    _loadPreviousNight();
  }

  /// Asks whether the previous operational night still has bookable slots.
  ///
  /// The app never works out "yesterday" itself: the device clock and the
  /// server clock differ, and around midnight that is exactly the
  /// disagreement that would offer the wrong night — or hide a real one.
  Future<void> _loadPreviousNight() async {
    final branchId = widget.branchId;
    final serviceId = widget.serviceId;

    if (branchId == null || serviceId == null) return;

    final result = await getIt<BookingRepoImp>().nightContext(
      branchId: branchId,
      serviceId: serviceId,
    );

    if (!mounted) return;

    result.fold(
      // A failure simply means no extra card. Guessing one from the device
      // clock is the thing this exists to avoid.
      (_) {},
      (context) => setState(() => _previousNight = context),
    );
  }

  @override
  void dispose() {
    _strip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());

    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final selected =
            state.selectedDay != null ? DateUtils.dateOnly(state.selectedDay!) : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("اختر تاريخ الحجز", style: AppTextStyles.font18Bold),
            HeightSpace(4.h),
            Text(
              "اختر اليوم الذي تريد اللعب فيه",
              style:
                  AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
            ),
            HeightSpace(14.h),

            SizedBox(
              height: 92.h,
              child: ListView.separated(
                controller: _strip,
                scrollDirection: Axis.horizontal,
                // The app is RTL, so the strip starts on the right where the
                // nearest dates belong.
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                // One extra card at the front when the night already under
                // way still has hours left. It is NOT a past date — it is
                // tonight, continuing past midnight — which is why the
                // calendar below still refuses historical dates.
                itemCount: _stripDays + (_previousNight.isOffered ? 1 : 0),
                separatorBuilder: (_, __) => WidthSpace(8.w),
                itemBuilder: (context, i) {
                  if (_previousNight.isOffered) {
                    if (i == 0) {
                      return _previousNightCard(context);
                    }
                    i -= 1;
                  }

                  final date = today.add(Duration(days: i));
                  return _dayCard(
                    context,
                    date: date,
                    isSelected: selected != null &&
                        DateUtils.isSameDay(selected, date),
                    label: _relativeLabel(i, date),
                  );
                },
              ),
            ),

            HeightSpace(12.h),
            _calendarButton(context, selected),

            if (selected != null) ...[
              HeightSpace(12.h),
              _selectedBanner(selected),
            ],
          ],
        );
      },
    );
  }

  /// "اليوم" and "غدًا" read faster than a date, so they replace the weekday
  /// name for the two days that matter most.
  String _relativeLabel(int index, DateTime date) {
    if (index == 0) return "اليوم";
    if (index == 1) return "غدًا";
    return arabicWeekdayName(date.weekday);
  }

  /// «الليلة» — the night already in progress, offered as its own card.
  ///
  /// Visually distinct from the ordinary day cards on purpose: it is not
  /// "yesterday", it is tonight running past midnight, and a customer who
  /// reads it as a past date will not tap it.
  ///
  /// The date sent back is the SERVER's, verbatim.
  Widget _previousNightCard(BuildContext context) {
    final state = context.watch<CalendarCubit>().state;
    final date = DateTime.parse(_previousNight.operationalDate!);
    final isSelected = state.selectedDay != null &&
        DateUtils.isSameDay(DateUtils.dateOnly(state.selectedDay!), date);

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () {
        context.read<CalendarCubit>().updateSelectedDay(date, date);
        widget.onDatePicked?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 76.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 100, 189, 70)
              : const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 100, 189, 70)
                : const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.45),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.nightlight_round,
              size: 9.sp,
              color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 255, 255, 255),
            ),
            HeightSpace(1.h),
            Text(
              'الليلة',
              style: AppTextStyles.font12Medium.copyWith(
                color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            HeightSpace(1.h),
            Text(
              '${date.day}',
              style: AppTextStyles.font18Bold.copyWith(
                fontSize: 13.sp,
                color: isSelected ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            Text(
              arabicMonthName(date.month),
              style: AppTextStyles.font12Regular.copyWith(
                color: isSelected
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCard(
    BuildContext context, {
    required DateTime date,
    required bool isSelected,
    required String label,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () {
        context.read<CalendarCubit>().updateSelectedDay(date, date);
        widget.onDatePicked?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 76.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 100, 189, 70) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 119, 230, 113)
                : AppColors.colorcommingItems,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 75, 170, 79).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.font12Regular.copyWith(
                color: isSelected ? Colors.white : AppColors.mainGrey,
              ),
            ),
            HeightSpace(4.h),
            Text(
              '${date.day}',
              style: AppTextStyles.font20Bold.copyWith(
                color: isSelected ? Colors.white : AppColors.darkBlue,
              ),
            ),
            Text(
              arabicMonthName(date.month),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.font10Regular.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.lightGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarButton(BuildContext context, DateTime? selected) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.colorcommingItems),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(Icons.calendar_month_outlined,
            size: 18.sp, color: AppColors.darkBlue),
        label: Text(
          "عرض التقويم",
          style: AppTextStyles.font14Bold.copyWith(color: AppColors.darkBlue),
        ),
        onPressed: () async {
          final picked = await showFullCalendarSheet(
            context,
            selected: selected,
          );

          if (picked != null && context.mounted) {
            context.read<CalendarCubit>().updateSelectedDay(picked, picked);
            widget.onDatePicked?.call();
          }
        },
      ),
    );
  }

  /// Confirms the choice in words, so a date picked from the calendar (and
  /// therefore off the visible strip) is never ambiguous.
  Widget _selectedBanner(DateTime selected) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 118, 173).withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromARGB(255, 0, 95, 173).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available,
              size: 18.sp, color: const Color.fromARGB(255, 78, 167, 196)),
          WidthSpace(8.w),
          Expanded(
            child: Text(
              "${arabicWeekdayName(selected.weekday)} "
              "${selected.day} ${arabicMonthName(selected.month)} ${selected.year}",
              style: AppTextStyles.font14Bold
                  .copyWith(color: const Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ],
      ),
    );
  }
}
