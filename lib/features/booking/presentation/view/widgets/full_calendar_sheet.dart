import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';

/// The month view, for dates further out than the quick strip covers.
///
/// Returns the chosen day, or null if dismissed. Past days are shown but
/// disabled rather than hidden — a greyed-out date explains itself, a missing
/// one just looks broken.
Future<DateTime?> showFullCalendarSheet(
  BuildContext context, {
  DateTime? selected,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FullCalendarContent(selected: selected),
  );
}

class _FullCalendarContent extends StatefulWidget {
  const _FullCalendarContent({this.selected});

  final DateTime? selected;

  @override
  State<_FullCalendarContent> createState() => _FullCalendarContentState();
}

class _FullCalendarContentState extends State<_FullCalendarContent> {
  late DateTime _month;
  DateTime? _picked;

  /// How far ahead a customer may book. Matches the two-month window the
  /// previous calendar allowed, so this changes presentation only.
  static const _monthsAhead = 2;

  @override
  void initState() {
    super.initState();
    final base = widget.selected ?? DateTime.now();
    _month = DateTime(base.year, base.month);
    _picked = widget.selected;
  }

  DateTime get _today => DateUtils.dateOnly(DateTime.now());
  DateTime get _firstMonth => DateTime(_today.year, _today.month);
  DateTime get _lastMonth =>
      DateTime(_today.year, _today.month + _monthsAhead);

  bool get _canGoBack => _month.isAfter(_firstMonth);
  bool get _canGoForward => _month.isBefore(_lastMonth);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            _header(),
            HeightSpace(12.h),
            _weekdayRow(),
            HeightSpace(6.h),
            _grid(),
            HeightSpace(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 67, 184, 77),
                  disabledBackgroundColor: AppColors.colorcommingItems,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: _picked == null
                    ? null
                    : () => Navigator.of(context).pop(_picked),
                child: Text(
                  "تأكيد التاريخ",
                  style:
                      AppTextStyles.font16Bold.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _arrow(
          icon: Icons.chevron_right,
          enabled: _canGoBack,
          onTap: () => setState(
              () => _month = DateTime(_month.year, _month.month - 1)),
        ),
        Expanded(
          child: Text(
            "${arabicMonthName(_month.month)} ${_month.year}",
            textAlign: TextAlign.center,
            style: AppTextStyles.font18Bold.copyWith(color: AppColors.darkBlue),
          ),
        ),
        _arrow(
          icon: Icons.chevron_left,
          enabled: _canGoForward,
          onTap: () => setState(
              () => _month = DateTime(_month.year, _month.month + 1)),
        ),
      ],
    );
  }

  Widget _arrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(
        icon,
        color: enabled ? AppColors.darkBlue : AppColors.colorcommingItems,
        size: 26.sp,
      ),
    );
  }

  /// Saturday-first, which is how a Libyan week reads.
  static const _weekdayOrder = [
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  ];

  /// Explicit short names: truncating would render both الأحد and الأربعاء
  /// as "الأ", so two different columns would carry the same heading.
  static const _weekdayShort = {
    DateTime.saturday: 'سبت',
    DateTime.sunday: 'أحد',
    DateTime.monday: 'إثن',
    DateTime.tuesday: 'ثلا',
    DateTime.wednesday: 'أرب',
    DateTime.thursday: 'خمي',
    DateTime.friday: 'جمع',
  };

  Widget _weekdayRow() {
    return Row(
      children: _weekdayOrder
          .map((d) => Expanded(
                child: Text(
                  _weekdayShort[d] ?? '',
                  
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font14Regular
                      .copyWith(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ))
          .toList(),
    );
  }

  Widget _grid() {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);

    // How many blanks before the 1st, given the week starts on Saturday.
    final leading = _weekdayOrder.indexOf(first.weekday);

    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _dayCell(DateTime(_month.year, _month.month, day)),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4.h,
      crossAxisSpacing: 4.w,
      children: cells,
    );
  }

  Widget _dayCell(DateTime date) {
    final isPast = date.isBefore(_today);
    final isToday = DateUtils.isSameDay(date, _today);
    final isPicked = _picked != null && DateUtils.isSameDay(date, _picked!);

    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: isPast ? null : () => setState(() => _picked = date),
      child: Container(
        decoration: BoxDecoration(
          color: isPicked ? const Color.fromARGB(255, 68, 162, 45) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: isToday && !isPicked
              ? Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1.2)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: AppTextStyles.font14Medium.copyWith(
            color: isPicked
                ? Colors.white
                // Disabled, not hidden: a greyed date explains itself.
                : isPast
                    ? AppColors.colorcommingItems
                    : AppColors.darkBlue,
          ),
        ),
      ),
    );
  }
}
