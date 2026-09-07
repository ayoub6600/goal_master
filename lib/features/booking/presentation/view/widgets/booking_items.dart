import 'package:flutter/material.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_case_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/cancellation_preview_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/format_to_hour.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/cancel_booking_cubit/cancel_booking_cubit.dart';

import 'package:goal_master/features/booking/presentation/view/widgets/status_container.dart';

class BookingItems extends StatelessWidget {
  const BookingItems({super.key, required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        push(RoutesKeys.kBookingItemsDetails, context, extra: booking);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 16.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primary,
            )),
        child: Column(
          children: [
            HeightSpace(6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: BookingIdentityLabel(booking: booking)),
                  Text(
                    "( ${_getPaymentStatusText(booking.paymentStatus)} )",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: _getPaymentStatusColor(booking.paymentStatus),
                    ),
                  ),
                ],
              ),
            ),
            if (booking.isPartOfSeries) ...[
              HeightSpace(8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: _monthlyBadge(booking.series!),
              ),
            ],
            HeightSpace(10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 7.w),
                  padding:
                      EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        width: 1.5,
                        color: Color(0xffDFF5E1),
                      )),
                  child: Row(
                    children: [
                      CircleAvatar(
                          radius: 20.w,
                          backgroundColor: AppColors.primary,
                          child: Image.asset(
                            Assets.imagesPngImageProfailIcon,
                          )),
                      WidthSpace(10.w),
                      Text(
                        booking.service,
                        style: AppTextStyles.font16Bold.copyWith(
                          color: Color(0xff204523),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 18.h,
                    horizontal: 30.w,
                  ),
                  decoration: BoxDecoration(
                      color: Color(0xffDFF5E1),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                      border: Border.all(
                        width: 1.5,
                        color: Color(0xffDFF5E1),
                      )),
                  child: Row(
                    children: [
                      Text(
                        booking.category,
                        style: AppTextStyles.font16Bold.copyWith(
                          color: Color(0xff204523),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            HeightSpace(16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Image.asset(
                    Assets.imagesPngImageLocation,
                    fit: BoxFit.cover,
                  ),
                  WidthSpace(10.w),
                  Text(
                    booking.address,
                    style: AppTextStyles.font16Bold.copyWith(
                      color: AppColors.fontColor,
                    ),
                  ),
                ],
              ),
            ),
            HeightSpace(16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          Assets.imagesPngImageClock,
                          fit: BoxFit.cover,
                        ),
                        WidthSpace(10.w),
                        Text(
                          formatToHour(booking.startTime),
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.font16Bold.copyWith(
                            color: AppColors.fontColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          Assets.imagesPngImageCalendar,
                          fit: BoxFit.cover,
                        ),
                        WidthSpace(10.w),
                        Text(
                          formatDate(booking.date),
                          textDirection: TextDirection.ltr,
                          //  booking.date,
                          style: AppTextStyles.font16Bold.copyWith(
                            color: AppColors.fontColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            HeightSpace(16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: StatusContainer(
                    status: booking.status,
                  ),
                ),
                WidthSpace(12.w),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("السعر  : ${booking.serviceAmount} دينار",
                        style: AppTextStyles.font18Bold.copyWith(
                          color: AppColors.primary,
                        )),
                  ),
                ),
              ],
            ),
            HeightSpace(12.h),
            // A booking inside a series never gets the plain "الغاء الحجز"
            // button: on its own that label can't say whether it means this
            // date or every date left. The series screen asks explicitly.
            if (booking.isPartOfSeries)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: ButtonApp(
                  text: "تفاصيل الحجز الشهري",
                  textColor: Colors.white,
                  backGround: AppColors.primary,
                  onTap: () => push(
                    RoutesKeys.kSeriesDetails,
                    context,
                    extra: booking.series!.seriesId,
                  ),
                ),
              )
            // ServiceStatus: 0 Pending, 1 Processing, 2 Approved, 3 Cancel,
            // 4 Done. A single wallet-paid booking is marked Done the
            // moment it's paid — saveBooking() confirms it immediately,
            // with no manager-approval step — so it can be far in the
            // future and still carry that status. Gating on {0, 1} hid the
            // button for exactly that case, and for any manager-approved
            // pay-on-arrival booking. The backend (via
            // CancellationPreviewSheet's own quote) is the real authority
            // on whether cancelling is still allowed — this only needs to
            // exclude what's already cancelled.
            else if (booking.status != 3)
              BlocConsumer<CancelBookingCubit, CancelBookingState>(
                listener: (context, state) {
                  print("state: $state");
                  if (state is CancelBookingSuccess) {
                    CustomSuccessToast(toastText: state.message);

                    context.read<BookingCubit>().refresh();
                    push(RoutesKeys.kHome, context);
                  } else if (state is CancelBookingFailure) {
                    CustomFailureToastWidget(toastText: state.message);
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: ButtonApp(
                            text: state is CancelBookingLoading
                                ? "جاري الغاء الحجز"
                                : "الغاء الحجز",
                            textColor: Colors.white,
                            backGround: AppColors.redcolor,
                            onTap: () async {
                              // Never cancel first and explain afterwards:
                              // the sheet fetches the exact refund and fee
                              // from the backend and only cancels once the
                              // customer has seen them and confirmed.
                              final cancelled =
                                  await CancellationPreviewSheet.show(
                                      context, booking.id);

                              if (cancelled == true && context.mounted) {
                                // Offered right here, while the customer is
                                // still looking at the outcome — an appeal
                                // buried in a menu is one nobody finds.
                                await BookingCaseSheet.show(
                                    context, booking.id);

                                if (context.mounted) {
                                  push(RoutesKeys.kHome, context);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// "حجز شهري · الموعد 2 من 4" plus, quietly beneath it, this session's own
  /// number — present for whoever needs to quote it, never competing with the
  /// series identity above for attention.
  Widget _monthlyBadge(BookingSeriesRef series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_repeat,
                      size: 14.sp, color: AppColors.primary),
                  WidthSpace(4.w),
                  Text(
                    "حجز شهري",
                    style: AppTextStyles.font12Bold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            WidthSpace(8.w),
            Flexible(
              child: Text(
                series.positionLabel,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font12Regular.copyWith(
                  color: AppColors.fontColor,
                ),
              ),
            ),
          ],
        ),
        HeightSpace(4.h),
        Text(
          "رقم الموعد" " #${booking.id}",
          style: AppTextStyles.font10Regular.copyWith(
            color: AppColors.fontColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'partially_paid':
        return 'مدفوعة جزئياً';
      case 'paid':
        return 'مدفوع';
      case 'pending':
        return 'غير مدفوع';
      default:
        return status; // Fallback to raw status if not matched
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'partially_paid':
        return Colors.orange; // لون برتقالي للمدفوعة جزئياً
      case 'paid':
        return Colors.green; // أخضر للمدفوع
      case 'pending':
        return Colors.red; // أحمر لغير المدفوع
      default:
        return AppColors.fontColor; // اللون الافتراضي
    }
  }
}

/// The booking's identity, as it must read identically to the Manager App.
///
/// A monthly occurrence's primary number used to be its OWN
/// sch_service_bookings.id — invisible to the venue, which only ever knows
/// the series id. The same booking then had two different "numbers"
/// depending on who was looking at it. The series id is now the identity;
/// the occurrence keeps its own id as a secondary detail, never the
/// headline.
///
/// A standalone widget (rather than a private helper on [BookingItems]) so it
/// can be pumped and measured on its own — the surrounding card carries
/// unrelated rows with their own narrow-screen behaviour that this identity
/// does not need to inherit into its own tests.
class BookingIdentityLabel extends StatelessWidget {
  const BookingIdentityLabel({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final series = booking.series;

    if (series == null) {
      // An ordinary booking, or a monthly row from a server that has not
      // sent series data yet. Unchanged: this is the id it has always shown.
      //
      // One Text rather than a Row of two: this card sits beside the payment
      // status label, and on a narrow phone two unconstrained Text widgets in
      // a Row can ask for more width than either has — a RenderFlex overflow,
      // not a readability choice. A single Text always respects the space it
      // is given.
      return Text(
        "# رقم الحجز" " : ${booking.id}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.font16Bold.copyWith(
          color: AppColors.fontColor,
        ),
      );
    }

    return Text(
      "الحجز الشهري" " #${series.seriesId}",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.font16Bold.copyWith(
        color: AppColors.fontColor,
      ),
    );
  }
}
