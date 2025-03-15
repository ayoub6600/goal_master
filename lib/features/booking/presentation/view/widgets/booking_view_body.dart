import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_list.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/fav_toggle_section.dart';

class BookingViewBody extends StatelessWidget {
  const BookingViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeightSpace(16.h),
        FavToggleSection(
            //toggleState: toggleState,
            ),
        HeightSpace(16.h),
        BookingList(),
      ],
    );
  }
}
