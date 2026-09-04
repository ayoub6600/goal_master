import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';

/// Moving one week of a recurring booking to a nearby slot.
///
/// The sheet says what it does not do as prominently as what it does: the
/// rest of the series is untouched. That is the customer's first worry, and
/// answering it up front is what makes the option feel safe to use.
///
/// Nothing here decides availability. Every slot shown came from the server,
/// and the server checks again at confirmation — a slot can go while the
/// customer is choosing, and the app must never pretend otherwise.
class ReplaceOccurrenceSheet extends StatefulWidget {
  const ReplaceOccurrenceSheet({
    super.key,
    required this.originalDate,
    required this.originalTimeLabel,
    required this.options,
  });

  final String originalDate;
  final String originalTimeLabel;
  final ReplacementOptions options;

  static Future<ReplacementSlot?> show(
    BuildContext context, {
    required String originalDate,
    required String originalTimeLabel,
    required ReplacementOptions options,
  }) {
    return showModalBottomSheet<ReplacementSlot>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => ReplaceOccurrenceSheet(
        originalDate: originalDate,
        originalTimeLabel: originalTimeLabel,
        options: options,
      ),
    );
  }

  @override
  State<ReplaceOccurrenceSheet> createState() => _ReplaceOccurrenceSheetState();
}

class _ReplaceOccurrenceSheetState extends State<ReplaceOccurrenceSheet> {
  /// Only the best few at first. A list of every free slot in the week turns
  /// a decision into a search.
  static const _initialPerGroup = 3;

  ReplacementSlot? _selected;
  bool _expanded = false;

  List<ReplacementSlot> _visible(List<ReplacementSlot> all) {
    if (_expanded || all.length <= _initialPerGroup) return all;
    return all.take(_initialPerGroup).toList();
  }

  bool get _hasMore =>
      widget.options.sameDay.length > _initialPerGroup ||
      widget.options.nearbyDays.length > _initialPerGroup;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.82),
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('غيّر هذا الموعد فقط',
                        style: TextStyle(
                            fontSize: 17.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2.h),
                    Text(
                      'باقي مواعيد حجزك الشهري لن تتغير',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _originalRow(),
          SizedBox(height: 14.h),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.options.sameDay.isNotEmpty) ...[
                    _groupTitle('نفس اليوم'),
                    ..._visible(widget.options.sameDay).map(_slotTile),
                    SizedBox(height: 8.h),
                  ],
                  if (widget.options.nearbyDays.isNotEmpty) ...[
                    _groupTitle('أيام قريبة'),
                    ..._visible(widget.options.nearbyDays).map(_slotTile),
                  ],
                  if (!widget.options.hasAny)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        'ما لقينا مواعيد قريبة متاحة لهذا الأسبوع.\n'
                        'تقدر تكمل بدون هذا الموعد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.5),
                      ),
                    ),
                  if (_hasMore && !_expanded)
                    TextButton(
                      onPressed: () => setState(() => _expanded = true),
                      child: const Text('عرض مواعيد أخرى'),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 13.h),
            ),
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop(_selected),
            child: const Text('تأكيد الموعد البديل',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// The week being moved, so the comparison is on screen rather than in the
  /// customer's memory.
  Widget _originalRow() {
    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy, size: 17.sp, color: AppColors.errorRed),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatArabicDate(widget.originalDate),
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.bold)),
                Text(widget.originalTimeLabel,
                    style: TextStyle(
                        fontSize: 11.5.sp, color: Colors.grey.shade700)),
              ],
            ),
          ),
          Text('غير متاح',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _groupTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: 4.h),
      child: Text(title,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _slotTile(ReplacementSlot slot) {
    final selected =
        _selected?.date == slot.date && _selected?.startTime == slot.startTime;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: () => setState(() => _selected = slot),
        child: Container(
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.grey.shade50,
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.dateLabel.isNotEmpty
                          ? slot.dateLabel
                          : formatArabicDate(slot.date),
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      slot.timeLabel.isNotEmpty
                          ? slot.timeLabel
                          : '${formatArabicTime(slot.startTime)} - ${formatArabicTime(slot.endTime)}',
                      style: TextStyle(
                          fontSize: 11.5.sp, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Text('متاح',
                  style: TextStyle(
                      fontSize: 11.5.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
              SizedBox(width: 8.w),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 19.sp,
                color: selected ? AppColors.primary : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
