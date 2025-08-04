import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/manager/notification_cubit/notification_cubit.dart';

import 'package:intl/intl.dart';

class ItemsNotification extends StatelessWidget {
  const ItemsNotification({
    super.key,
    required this.notification,
  });

  final NotificationItem notification;

  bool get isRead =>
      notification.readAt != null && notification.readAt!.isNotEmpty;

  String getFormattedDate(String isoDate) {
    final dateTime = DateTime.tryParse(isoDate);
    if (dateTime == null) return '';
    return DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final message = notification.data.message;
    final createdAt =
        getFormattedDate(notification.createdAt.toIso8601String());
    final int? bookingId = notification.data.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[100] : AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isRead ? Colors.transparent : AppColors.primary.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRead)
            Container(
              width: 8.r,
              height: 8.r,
              margin: EdgeInsets.only(top: 8.h, right: 4.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.grey[200]
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              Assets.imagesPngImageNotification,
              height: 24.h,
              width: 24.w,
              color: AppColors.primary,
            ),
          ),
          WidthSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.font14SemiBold.copyWith(
                    color: isRead ? Colors.grey[600] : AppColors.black,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                HeightSpace(6.h),
                Text(
                  createdAt,
                  style: AppTextStyles.font12Regular.copyWith(
                    color: isRead ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    isRead
                        ? null
                        : context
                            .read<NotificationCubit>()
                            .markAsRead(notification.id);
                    push(RoutesKeys.kNotificationItemsDetails, context,
                        extra: bookingId);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          "تفاصيل",
                          style: AppTextStyles.font12Regular.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              isRead
                  ? null
                  : context
                      .read<NotificationCubit>()
                      .markAsRead(notification.id);

              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Text(
                    'تفاصيل الإشعار',
                    style: AppTextStyles.font20Bold,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message, style: AppTextStyles.font18Bold),
                      HeightSpace(12.h),
                      Text(
                        'تاريخ الإشعار: $createdAt',
                        style: AppTextStyles.font14SemiBold.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (bookingId != null) ...[
                        HeightSpace(12.h),
                        Text(
                          'رقم الحجز: $bookingId',
                          style: AppTextStyles.font14SemiBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // actions: [
                  //   if (bookingId != null)
                  //     TextButton(
                  //       onPressed: () {
                  //         Navigator.pop(ctx);
                  //         showDialog(
                  //           barrierDismissible: false,
                  //           context: context,
                  //           builder: (_) => BlocProvider(
                  //             create: (_) => BookingDetailsCubit(
                  //               getIt<BookingRepoImp>(),
                  //               bookingId,
                  //             )..getBookingInfo(),
                  //             child: AlertDialog(
                  //               backgroundColor: AppColors.white,
                  //               title: Text(
                  //                 'تفاصيل الحجز',
                  //                 style: AppTextStyles.font16Bold,
                  //               ),
                  //               content: BlocBuilder<BookingDetailsCubit,
                  //                   BookingDetailsState>(
                  //                 builder: (context, state) {
                  //                   if (state is BookingDetailsLoading) {
                  //                     return SizedBox(
                  //                       height: 100,
                  //                       child: Center(
                  //                           child: CircularProgressIndicator()),
                  //                     );
                  //                   } else if (state is BookingDetailsSuccess) {
                  //                     return ShowDetailsNotification(
                  //                         item: state.bookingDetails);
                  //                   } else if (state is BookingDetailsError) {
                  //                     return Text(
                  //                       'حدث خطأ: ${state.message}',
                  //                       style: TextStyle(color: Colors.red),
                  //                     );
                  //                   }
                  //                   return const SizedBox();
                  //                 },
                  //               ),
                  //               actions: [
                  //                 TextButton(
                  //                   onPressed: () => Navigator.pop(context),
                  //                   child: Text(
                  //                     'إغلاق',
                  //                     style:
                  //                         AppTextStyles.font14SemiBold.copyWith(
                  //                       color: Colors.grey,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //       child: Text(
                  //         'عرض تفاصيل الحجز',
                  //         style: AppTextStyles.font14SemiBold.copyWith(
                  //           color: AppColors.primary,
                  //         ),
                  //       ),
                  //     ),
                  //   TextButton(
                  //     onPressed: () => Navigator.pop(ctx),
                  //     child: Text(
                  //       'إغلاق',
                  //       style: AppTextStyles.font14SemiBold.copyWith(
                  //         color: Colors.grey,
                  //       ),
                  //     ),
                  //   ),
                  // ],
                ),
              );
            },
            child: Icon(
              Icons.chevron_right,
              color: isRead ? Colors.grey[400] : AppColors.primary,
              size: 24.w,
            ),
          ),
        ],
      ),
    );
  }
}
