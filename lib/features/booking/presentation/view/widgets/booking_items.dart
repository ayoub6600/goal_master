import 'package:flutter/material.dart';
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
                  Row(
                    children: [
                      Text(
                        "# رقم الحجز" " : ",
                        style: AppTextStyles.font16Bold.copyWith(
                          color: AppColors.fontColor,
                        ),
                      ),
                      WidthSpace(10.w),
                      Text(
                        booking.id.toString(),
                        style: AppTextStyles.font16Bold.copyWith(
                          color: AppColors.fontColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "( ${_getPaymentStatusText(booking.paymentStatus)} )",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: _getPaymentStatusColor(booking.paymentStatus),
                    ),
                  ),
                ],
              ),
            ),
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
                StatusContainer(
                  status: booking.status,
                ),
                WidthSpace(12.w),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("السعر  : ${booking.serviceAmount} دينار",
                      style: AppTextStyles.font18Bold.copyWith(
                        color: AppColors.primary,
                      )),
                ),
              ],
            ),
            HeightSpace(12.h),
            if (booking.status == 0 || booking.status == 1)
              BlocConsumer<CancelBookingCubit, CancelBookingState>(
                listener: (context, state) {
                  print("state: $state");
                  if (state is CancelBookingSuccess) {
                    CustomSuccessToast(toastText: state.message);

                    context.read<BookingCubit>().refresh();
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
                            text: "الغاء الحجز",
                            textColor: Colors.white,
                            backGround: AppColors.redcolor,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                builder: (context2) {
                                  return Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'هل تريد إلغاء الحجز؟',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 20.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context2); // اغلاق المودال
                                                  context
                                                      .read<
                                                          CancelBookingCubit>()
                                                      .cancelBooking(
                                                          booking.id);
                                                },
                                                child: Text('نعم',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('لا',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
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
