import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/status_container.dart';

class BuildTitleRow extends StatelessWidget {
  const BuildTitleRow({
    super.key,
    required this.booking,
  });
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.branch,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font20Bold
                      .copyWith(color: const Color(0xff204523))),
              Text(booking.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font16Medium
                      .copyWith(color: AppColors.fontColor)),
            ],
          ),
        ),
        WidthSpace(8.w),
        StatusContainer(status: booking.status),
      ],
    );
  }
}
