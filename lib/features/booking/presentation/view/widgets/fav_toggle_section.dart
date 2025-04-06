import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/presentation/manager/toggle_booking/booking_toggle_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/toggle_booking/booking_toggle_state.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/fav_toggle_item.dart';

class FavToggleSection extends StatelessWidget {
  const FavToggleSection({
    super.key,
    required this.toggleState,
  });

  final BookingToggleState toggleState;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.all(4.r),
      decoration: ShapeDecoration(
        color: AppColors.lightWhite3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FavToggleItem(
              title: 'حجوزاتي الحالية',
              onTap: () {
                context.read<ToggleCubit>().toggle(
                      isDoc: true,
                    );
              },
              //  isSelected: false,
              isSelected: toggleState is BookingDoctors,
            ),
          ),
          Expanded(
            child: FavToggleItem(
              title: "حجوزاتي السابقة",
              onTap: () {
                context.read<ToggleCubit>().toggle(
                      isDoc: false,
                    );
                //context.read<FavToggleCubit>().toggle();
              },
              isSelected: toggleState is BookingArticles,
            ),
          ),
        ],
      ),
    );
  }
}
