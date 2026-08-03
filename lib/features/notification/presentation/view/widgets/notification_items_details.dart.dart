import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/booking/presentation/manager/%20booking_details_cubit/booking_details_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/%20booking_details_cubit/booking_details_state.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_details_section.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/build_header_image.dart';
import 'package:intl/intl.dart';

class NotificationItemsDetails extends StatelessWidget {
  const NotificationItemsDetails({
    super.key,
    required this.notification,
  });

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    if (notification.isWalletTransaction) {
      return _WalletNotificationDetails(notification: notification);
    }

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<BookingDetailsCubit, BookingDetailsState>(
          builder: (context, state) {
            if (state is BookingDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingDetailsError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is BookingDetailsSuccess) {
              final booking = state.bookingDetails;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const BuildHeaderImage(),
                          BuildDetailsSection(
                            booking: booking,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        //  if (booking.status == 3)
                        // Row(
                        //   children: [
                        //     DepositBookingButton(bookingDetails: booking),
                        //   ],
                        // ),
                        HeightSpace(16.h),
                        // Row(
                        //   children: [
                        //     if (booking.status != 3)
                        //       CancelBookingButton(
                        //         id: booking.id,
                        //       ),
                        //     WidthSpace(8.w),
                        //     UpdateBookingStatusView(
                        //       id: booking.id,
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('No Data'));
          },
        ),
      ),
    );
  }
}

class _WalletNotificationDetails extends StatelessWidget {
  const _WalletNotificationDetails({required this.notification});

  final NotificationItem notification;

  @override
  Widget build(BuildContext context) {
    final createdAt = notification.data.createdAt.isNotEmpty
        ? notification.data.createdAt
        : notification.createdAt.toIso8601String();

    final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(
      DateTime.tryParse(createdAt) ?? notification.createdAt,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل العملية المالية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.data.message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                HeightSpace(16.h),
                _detailRow('نوع العملية', 'شحن من الإدارة'),
                _detailRow(
                  'المبلغ',
                  '${notification.data.amount.toStringAsFixed(2)} د.ل',
                ),
                _detailRow(
                  'الوصف',
                  notification.data.description.isEmpty
                      ? 'سبب العملية غير متوفر'
                      : notification.data.description,
                ),
                _detailRow('رقم العملية', notification.data.id.toString()),
                _detailRow('تاريخ العملية', formattedDate),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
