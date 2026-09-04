import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/features/booking/presentation/manager/series_details_cubit/series_details_cubit.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/renewal_card.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/renewal_price_changed_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/series_cancel_options_sheet.dart';

/// One recurring booking: where, when, how it stands, and each of its four
/// dates with what has happened to it.
class SeriesDetailsView extends StatefulWidget {
  const SeriesDetailsView({super.key, required this.seriesId, BookingRepo? bookingRepo})
      : _bookingRepo = bookingRepo;

  final int seriesId;

  /// Overridable so a test can substitute a fake without touching the global
  /// service locator. Always null in the running app.
  final BookingRepo? _bookingRepo;

  @override
  State<SeriesDetailsView> createState() => _SeriesDetailsViewState();
}

class _SeriesDetailsViewState extends State<SeriesDetailsView> {
  /// The occurrence currently being fetched for its own details, so its row
  /// can show a spinner instead of the chevron and refuse a second tap while
  /// the first is still in flight.
  int? _openingBookingId;

  @override
  void initState() {
    super.initState();
    context.read<SeriesDetailsCubit>().load(widget.seriesId);
  }

  /// Opens ONE occurrence's own booking details — the same screen and route
  /// an ordinary booking already opens, reused rather than duplicated.
  ///
  /// That screen takes a full `Booking`, not just an id, and the series
  /// payload does not carry the fields a `Booking` needs (payment, address,
  /// category) — only the shared series context and this occurrence's date,
  /// time and status. So this fetches the occurrence's own authoritative
  /// record first, through the exact endpoint every other "view one booking"
  /// path already uses, and only then pushes — never a partially-built
  /// stand-in.
  Future<void> _openOccurrence(SeriesOccurrence occurrence) async {
    if (_openingBookingId != null) return; // one open in flight at a time

    setState(() => _openingBookingId = occurrence.bookingId);

    final repo = widget._bookingRepo ?? getIt<BookingRepoImp>();
    final result = await repo.getBookingInfo(occurrence.bookingId);

    if (!mounted) return;
    setState(() => _openingBookingId = null);

    result.fold(
      (failure) => showCustomFailureToast(failure.errMessage),
      (booking) => push(RoutesKeys.kBookingItemsDetails, context, extra: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "تفاصيل الحجز الشهري",
      allowBack: true,
      child: BlocConsumer<SeriesDetailsCubit, SeriesDetailsState>(
        listener: (context, state) async {
          if (state is SeriesDetailsLoaded && state.actionError != null) {
            showCustomFailureToast(state.actionError!);
          }

          if (state is SeriesRenewed) {
            // One message for the whole renewed series, never one per date.
            CustomSuccessToast(toastText: "تم تجديد حجزك الشهري بنجاح");
            context.read<SeriesDetailsCubit>().load(state.series.seriesId);
          }

          if (state is SeriesRenewalPriceChanged) {
            // Nothing was charged. The new price is shown and has to be
            // accepted before anything is taken.
            final accepted = await showRenewalPriceChangedSheet(
              context,
              newTotal: state.newTotal,
              newPricePerOccurrence: state.newPricePerOccurrence,
              previousTotal: state.offer.totalAmount,
            );

            if (context.mounted && accepted == true) {
              context
                  .read<SeriesDetailsCubit>()
                  .renewAtNewPrice(state.newPriceSignature);
            } else if (context.mounted) {
              context.read<SeriesDetailsCubit>().load(state.offer.seriesId);
            }
          }

          if (state is SeriesRenewalPlanChanged) {
            showCustomFailureToast(state.message);
            if (context.mounted) {
              context.read<SeriesDetailsCubit>().load(state.offer.seriesId);
            }
          }
        },
        builder: (context, state) {
          if (state is SeriesDetailsLoading || state is SeriesDetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // The transient renewal outcomes are handled in the listener; the
          // screen keeps showing the series while they resolve.
          if (state is SeriesRenewed ||
              state is SeriesRenewalPriceChanged ||
              state is SeriesRenewalPlanChanged) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SeriesDetailsFailure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.font14Regular
                      .copyWith(color: AppColors.errorRed),
                ),
              ),
            );
          }

          final loaded = state as SeriesDetailsLoaded;
          final series = loaded.series;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only while the series is in its renewal window and has
                    // not been answered — most of the time there is nothing
                    // here at all.
                    if (loaded.renewalOffer?.isOfferable == true)
                      RenewalCard(offer: loaded.renewalOffer!),
                    _header(series),
                    HeightSpace(12.h),
                    _paymentSummary(series),
                    HeightSpace(16.h),
                    Text("المواعيد", style: AppTextStyles.font16Bold),
                    HeightSpace(8.h),
                    ...series.occurrences.map(
                      (o) => _occurrenceRow(context, series, o),
                    ),
                    if (series.hasSkippedWeeks) ...[
                      HeightSpace(12.h),
                      _skippedWeeks(series),
                    ],
                    HeightSpace(20.h),
                    _cancelButton(context, series),
                    HeightSpace(24.h),
                  ],
                ),
              ),
              if (loaded.isBusy)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BookingSeries series) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightWhite3,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.colorcommingItems),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  series.branch.isEmpty ? "الملعب" : series.branch,
                  style: AppTextStyles.font18Bold
                      .copyWith(color: AppColors.darkBlue),
                ),
              ),
              _statusChip(series),
            ],
          ),
          HeightSpace(8.h),
          Row(
            children: [
              Icon(Icons.event_repeat,
                  size: 18.sp, color: AppColors.mainGrey),
              WidthSpace(6.w),
              Expanded(
                child: Text(
                  "كل ${series.dayName} الساعة ${formatArabicTime(series.startTime)}",
                  style: AppTextStyles.font14Medium
                      .copyWith(color: AppColors.mainGrey),
                ),
              ),
            ],
          ),
          HeightSpace(6.h),
          Text(
            // Dates, never a month name: the fourth date routinely falls in
            // the following month and calling it "a month" would mislead.
            "من ${formatArabicDate(series.startDate)} "
            "إلى ${formatArabicDateWithYear(series.endDate)}",
            style:
                AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }

  /// What has been collected against the series, in the server's own
  /// figures — never a client sum of the occurrences below, so this can
  /// never disagree with the number that actually gates the money.
  Widget _paymentSummary(BookingSeries series) {
    final (label, color) = switch (series.paymentStatus) {
      'paid' => ("مدفوع بالكامل", AppColors.successGreen),
      'partial' => ("مدفوع جزئيًا", const Color(0xffB26A00)),
      _ => ("غير مدفوع", AppColors.errorRed),
    };

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
                  "الإجمالي" " ${series.totalAmount.toStringAsFixed(0)} د.ل",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.font14Bold
                      .copyWith(color: AppColors.darkBlue),
                ),
              ),
            ],
          ),
          if (series.remainingAmount > 0) ...[
            HeightSpace(6.h),
            Text(
              "المتبقي" " ${series.remainingAmount.toStringAsFixed(0)} د.ل",
              style:
                  AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
            ),
          ],
        ],
      ),
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

  Widget _occurrenceRow(
    BuildContext context,
    BookingSeries series,
    SeriesOccurrence occurrence,
  ) {
    final (icon, color, label) = switch (occurrence) {
      SeriesOccurrence(isCancelled: true) => (
          Icons.cancel,
          AppColors.errorRed,
          "ملغي"
        ),
      SeriesOccurrence(isDone: true) => (
          Icons.check_circle,
          AppColors.successGreen,
          "تم"
        ),
      _ => (Icons.schedule, AppColors.mainBlue, "قادم"),
    };

    final isOpening = _openingBookingId == occurrence.bookingId;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          // The whole row opens THIS occurrence's own booking details —
          // never the series, and never any other date. The "⋮" beside it is
          // a second, independent tap target for cancellation only, and sits
          // inside this same row without stealing its tap: Flutter resolves
          // the IconButton's own gesture first, so pressing it never also
          // fires the row's onTap.
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _openOccurrence(occurrence),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.colorcommingItems),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: color),
                WidthSpace(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              formatArabicDate(occurrence.date),
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font14Bold.copyWith(
                                color: occurrence.isCancelled
                                    ? AppColors.lightGrey
                                    : AppColors.darkBlue,
                                decoration: occurrence.isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (occurrence.isReplacement) ...[
                            WidthSpace(6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlueLight2,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                "موعد بديل",
                                style: AppTextStyles.font10Regular
                                    .copyWith(color: AppColors.darkBlue),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        // Laid out LTR as one unit: Latin digits either side
                        // of an Arabic dash reorder under RTL otherwise, and
                        // a 10–11 PM slot has read as "11 – 10" before.
                        "${formatArabicTime(occurrence.startTime)} – "
                        "${formatArabicTime(occurrence.endTime)}",
                        textDirection: TextDirection.ltr,
                        style: AppTextStyles.font12Regular
                            .copyWith(color: AppColors.mainGrey),
                      ),
                      Text(
                        "الموعد ${occurrence.sequence} من ${series.occurrenceCount}",
                        style: AppTextStyles.font12Regular
                            .copyWith(color: AppColors.lightGrey),
                      ),
                      Text(
                        "رقم الموعد" " #${occurrence.bookingId}",
                        style: AppTextStyles.font10Regular
                            .copyWith(color: AppColors.lightGrey),
                      ),
                    ],
                  ),
                ),
                Text(label,
                    style: AppTextStyles.font12Bold.copyWith(color: color)),
                if (isOpening) ...[
                  WidthSpace(8.w),
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else ...[
                  WidthSpace(4.w),
                  Icon(Icons.chevron_left, size: 20.sp, color: AppColors.lightGrey),
                ],
                // Offered only where the backend says it is allowed, so the
                // app can never present an action the server would refuse.
                if (occurrence.canCancel) ...[
                  IconButton(
                    // Compact and tightly constrained: the default 48dp
                    // Material tap target, added to the icon, the label word
                    // and the chevron/spinner already in this row, is what
                    // pushed it past a 320px phone's width.
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                    icon: Icon(Icons.more_vert,
                        size: 20.sp, color: AppColors.mainGrey),
                    onPressed: () => showSeriesCancelOptions(
                      context,
                      series: series,
                      occurrence: occurrence,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Why the series runs longer than four weeks. Shown rather than left
  /// unexplained — the customer approved this skip at booking time, and the
  /// booking should still be able to account for itself weeks later.
  Widget _skippedWeeks(BookingSeries series) {
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
            "مواعيد تم تخطيها",
            style:
                AppTextStyles.font14Bold.copyWith(color: AppColors.mainGrey),
          ),
          HeightSpace(8.h),
          ...series.skippedWeeks.map(
            (w) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.remove_circle_outline,
                      size: 16.sp, color: AppColors.lightGrey),
                  WidthSpace(8.w),
                  Expanded(
                    child: Text(
                      "${formatArabicDate(w.date)} — كان محجوزًا",
                      style: AppTextStyles.font12Regular
                          .copyWith(color: AppColors.mainGrey),
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

  Widget _cancelButton(BuildContext context, BookingSeries series) {
    final hasCancellable = series.occurrences.any((o) => o.canCancel);
    if (!hasCancellable) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.errorRed),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(Icons.event_busy, color: AppColors.errorRed, size: 20.sp),
        label: Text(
          "خيارات الإلغاء",
          style: AppTextStyles.font16Bold.copyWith(color: AppColors.errorRed),
        ),
        onPressed: () => showSeriesCancelOptions(context, series: series),
      ),
    );
  }
}
