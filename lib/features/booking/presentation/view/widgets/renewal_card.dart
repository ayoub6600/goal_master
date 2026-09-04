import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/presentation/manager/series_details_cubit/series_details_cubit.dart';

/// The renewal offer: which slots are being held, until when, what it costs,
/// and the two answers.
///
/// Careful about tense throughout. Nothing has been renewed and nothing has
/// been paid — the slots are held, which is a promise to keep them free, not
/// a booking. Wording that implied otherwise would have customers believing
/// they had a booking they had not paid for.
class RenewalCard extends StatelessWidget {
  const RenewalCard({super.key, required this.offer});

  final RenewalOffer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.mainBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.mainBlue.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.autorenew, color: AppColors.mainBlue, size: 24.sp),
              WidthSpace(10.w),
              Expanded(
                child: Text(
                  "حجزك الشهري يقترب من الانتهاء",
                  style: AppTextStyles.font16Bold
                      .copyWith(color: AppColors.darkBlue),
                ),
              ),
            ],
          ),
          HeightSpace(10.h),

          if (offer.holds.isNotEmpty) ...[
            Text(
              offer.holdsExpireAt != null
                  ? "حافظنا لك مؤقتًا على المواعيد التالية حتى "
                      "${formatArabicDate(offer.holdsExpireAt!.toIso8601String())} "
                      "الساعة ${_clock(offer.holdsExpireAt!)}"
                  : "حافظنا لك مؤقتًا على المواعيد التالية",
              style: AppTextStyles.font12Regular
                  .copyWith(color: AppColors.mainGrey),
            ),
            HeightSpace(10.h),
          ],

          ..._slotRows(),

          if (offer.skippedDates.isNotEmpty) ...[
            HeightSpace(6.h),
            Text(
              "تم تخطي موعد محجوز مسبقًا، وستحصل على "
              "${offer.holds.isEmpty ? 4 : offer.holds.length} مواعيد.",
              style:
                  AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
            ),
          ],

          HeightSpace(14.h),
          _price(),
          HeightSpace(14.h),
          _actions(context),
        ],
      ),
    );
  }

  /// The held slots, or the planned ones if holds are switched off. A week
  /// that was stepped over is shown struck through rather than hidden.
  List<Widget> _slotRows() {
    if (offer.plan.isNotEmpty) {
      return offer.plan.map((week) {
        final skipped = week.isSkipped;

        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            children: [
              Icon(
                skipped ? Icons.remove_circle_outline : Icons.lock_outline,
                size: 18.sp,
                color: skipped ? AppColors.mainGrey : AppColors.mainBlue,
              ),
              WidthSpace(8.w),
              Expanded(
                child: Text(
                  formatArabicDate(week.date),
                  style: AppTextStyles.font14Regular.copyWith(
                    color: skipped ? AppColors.mainGrey : AppColors.darkBlue,
                    decoration: skipped ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (skipped)
                Text(
                  "محجوز مسبقًا",
                  style: AppTextStyles.font12Bold
                      .copyWith(color: AppColors.mainGrey),
                )
              else if (week.isExtension)
                Text(
                  "موعد بديل",
                  style: AppTextStyles.font12Bold
                      .copyWith(color: AppColors.successGreen),
                ),
            ],
          ),
        );
      }).toList();
    }

    return offer.holds
        .map((hold) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 18.sp, color: AppColors.mainBlue),
                  WidthSpace(8.w),
                  Expanded(
                    child: Text(
                      formatArabicDate(hold.date),
                      style: AppTextStyles.font14Regular
                          .copyWith(color: AppColors.darkBlue),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  /// The total, shown before any button is pressed — and the old price
  /// alongside it when it has changed, so a rise is never a surprise on the
  /// balance.
  Widget _price() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.colorcommingItems),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "سعر التجديد: ${offer.totalAmount.toStringAsFixed(2)} د.ل",
            style:
                AppTextStyles.font16Bold.copyWith(color: AppColors.darkBlue),
          ),
          HeightSpace(4.h),
          Text(
            "${offer.pricePerOccurrence.toStringAsFixed(2)} د.ل للموعد الواحد",
            style:
                AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
          ),
          if (offer.priceChanged) ...[
            HeightSpace(6.h),
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14.sp, color: AppColors.errorRed),
                WidthSpace(4.w),
                Expanded(
                  child: Text(
                    "تغيّر السعر منذ حجزك السابق "
                    "(${offer.previousPricePerOccurrence.toStringAsFixed(2)} د.ل).",
                    style: AppTextStyles.font12Regular
                        .copyWith(color: AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ],
          HeightSpace(6.h),
          Text(
            // Said plainly: the slots are held, the booking is not made.
            "لن يتم خصم أي مبلغ قبل تأكيدك.",
            style:
                AppTextStyles.font12Regular.copyWith(color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              padding: EdgeInsets.symmetric(vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => context.read<SeriesDetailsCubit>().renew(),
            child: Text(
              "تجديد الحجز",
              style: AppTextStyles.font14Bold.copyWith(color: Colors.white),
            ),
          ),
        ),
        WidthSpace(10.w),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.mainGrey),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => _confirmDecline(context),
            child: Text(
              "لا أريد التجديد",
              style:
                  AppTextStyles.font14Bold.copyWith(color: AppColors.darkBlue),
            ),
          ),
        ),
      ],
    );
  }

  /// Declining frees the slots for everyone else immediately, which is not
  /// obvious and not undoable — so it is confirmed.
  Future<void> _confirmDecline(BuildContext context) async {
    final cubit = context.read<SeriesDetailsCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("إلغاء أولوية التجديد؟", style: AppTextStyles.font16Bold),
        content: Text(
          "ستصبح المواعيد المحجوزة لك متاحة للزبائن الآخرين فورًا، "
          "ولا يمكن التراجع.",
          style:
              AppTextStyles.font14Regular.copyWith(color: AppColors.mainGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text("تراجع", style: AppTextStyles.font14Bold),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              "تأكيد",
              style:
                  AppTextStyles.font14Bold.copyWith(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      cubit.declineRenewal();
    }
  }

  String _clock(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minutes = value.minute.toString().padLeft(2, '0');

    return "$hour:$minutes ${value.hour < 12 ? 'صباحًا' : 'مساءً'}";
  }
}
