import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
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
      children: [
        Text(
          booking.branch,
          style: AppTextStyles.font20Bold.copyWith(
            color: Color(0xff204523),
          ),
        ),
        Spacer(),
        //rating widget
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatusContainer(
              status: booking.status,
            )
          ],
        ),
      ],
    );
  }
}
