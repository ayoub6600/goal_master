import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';

/// One recurring booking, as one card — where the list used to show it as
/// four (one per session, each headlined by that session's own id, none of
/// them representing the commitment as a whole).
///
/// [representative] is whichever occurrence the list encountered first for
/// this series; it supplies the service name, which the series payload does
/// not carry, and is also what this card falls back to rendering if the full
/// series cannot be loaded — so a slow or failed fetch degrades to exactly
/// what the customer saw before this card existed, never a blank space or a
/// crash.
class MonthlySeriesCard extends StatefulWidget {
  const MonthlySeriesCard({
    super.key,
    required this.seriesId,
    required this.representative,
    BookingRepo? bookingRepo,
  }) : _bookingRepo = bookingRepo;

  final int seriesId;
  final Booking representative;

  /// Overridable so a test can substitute a fake without touching the global
  /// service locator, which is keyed by the concrete [BookingRepoImp] and
  /// cannot hold a second, fake registration alongside the real one. The
  /// running app never passes this — it gets the real singleton below.
  final BookingRepo? _bookingRepo;

  @override
  State<MonthlySeriesCard> createState() => _MonthlySeriesCardState();
}

class _MonthlySeriesCardState extends State<MonthlySeriesCard> {
  late final Future<BookingSeries?> _load;

  @override
  void initState() {
    super.initState();
    // Fetched once per card instance, not per rebuild/scroll frame — the
    // Future is created here, in initState, and reused by the FutureBuilder
    // below.
    final repo = widget._bookingRepo ?? getIt<BookingRepoImp>();
    _load = repo.getSeries(widget.seriesId).then(
          (result) => result.fold((_) => null, (series) => series),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookingSeries?>(
      future: _load,
      builder: (context, snapshot) {
        final series = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return _skeleton();
        }

        // The series could not be loaded — a stale link, a network hiccup, an
        // older payload the resource does not yet fully populate. The
        // customer still sees THIS booking; they just see it the way they
        // always have, one card per session.
        if (series == null) {
          return BookingItems(booking: widget.representative);
        }

        return _card(context, series);
      },
    );
  }

  Widget _skeleton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.lightWhite3,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _card(BuildContext context, BookingSeries series) {
    final next = series.nextOccurrence(DateTime.now());

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "الحجز الشهري" " #${series.seriesId}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font16Bold
                      .copyWith(color: AppColors.fontColor),
                ),
              ),
              _statusChip(series),
            ],
          ),
          HeightSpace(10.h),
          Text(
            widget.representative.service,
            style: AppTextStyles.font18Bold.copyWith(color: AppColors.darkBlue),
          ),
          HeightSpace(4.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16.sp, color: AppColors.mainGrey),
              WidthSpace(6.w),
              Expanded(
                child: Text(
                  series.branch.isEmpty ? widget.representative.branch : series.branch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font14Regular
                      .copyWith(color: AppColors.mainGrey),
                ),
              ),
            ],
          ),
          HeightSpace(12.h),
          Row(
            children: [
              Icon(Icons.event_repeat, size: 16.sp, color: AppColors.mainGrey),
              WidthSpace(6.w),
              Text(
                "${series.occurrenceCount} مواعيد",
                style: AppTextStyles.font12Regular
                    .copyWith(color: AppColors.mainGrey),
              ),
              if (series.cancelledCount > 0) ...[
                WidthSpace(6.w),
                Text(
                  "(${series.cancelledCount} ملغاة)",
                  style: AppTextStyles.font12Regular
                      .copyWith(color: AppColors.lightGrey),
                ),
              ],
            ],
          ),
          HeightSpace(4.h),
          Text(
            "من ${formatArabicDate(series.startDate)} "
            "إلى ${formatArabicDateWithYear(series.endDate)}",
            style: AppTextStyles.font12Regular.copyWith(color: AppColors.lightGrey),
          ),
          HeightSpace(12.h),
          if (next != null) _nextOccurrenceBlock(next) else _finishedBlock(),
          HeightSpace(12.h),
          _paymentSummary(series),
          HeightSpace(14.h),
          ButtonApp(
            text: "عرض تفاصيل الحجز الشهري",
            textColor: Colors.white,
            backGround: AppColors.primary,
            onTap: () => push(
              RoutesKeys.kSeriesDetails,
              context,
              extra: series.seriesId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextOccurrenceBlock(SeriesOccurrence next) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xffDFF5E1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  "الموعد القادم",
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font12Bold
                      .copyWith(color: const Color(0xff204523)),
                ),
              ),
              if (next.isReplacement) ...[
                WidthSpace(8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "موعد بديل",
                    style: AppTextStyles.font10Regular
                        .copyWith(color: const Color(0xff204523)),
                  ),
                ),
              ],
            ],
          ),
          HeightSpace(4.h),
          Text(
            formatArabicDateWithYear(next.date),
            style: AppTextStyles.font14Bold.copyWith(color: AppColors.darkBlue),
          ),
          Text(
            "${formatArabicTime(next.startTime)} – ${formatArabicTime(next.endTime)}",
            style: AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }

  Widget _finishedBlock() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.lightWhite3,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        "اكتملت كل مواعيد هذا الحجز الشهري",
        style: AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
      ),
    );
  }

  Widget _paymentSummary(BookingSeries series) {
    final (label, color) = switch (series.paymentStatus) {
      'paid' => ("مدفوع بالكامل", Colors.green),
      'partial' => ("مدفوع جزئيًا", Colors.orange),
      _ => ("غير مدفوع", AppColors.redcolor),
    };

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: AppTextStyles.font12Bold.copyWith(color: color),
          ),
        ),
        WidthSpace(8.w),
        Flexible(
          child: Text(
            "السعر" " : ${series.pricePerOccurrence.toStringAsFixed(0)} د.ل / موعد",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.font12Regular.copyWith(color: AppColors.fontColor),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(BookingSeries series) {
    final color = switch (series.status) {
      'active' => AppColors.successGreen,
      'completed' => AppColors.mainBlue,
      'cancelled' => AppColors.errorRed,
      _ => AppColors.mainGrey,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        series.statusLabel,
        style: AppTextStyles.font12Bold.copyWith(color: color),
      ),
    );
  }
}
