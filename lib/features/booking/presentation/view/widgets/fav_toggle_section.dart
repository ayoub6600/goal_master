import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/fav_toggle_item.dart';

class FavToggleSection extends StatelessWidget {
  const FavToggleSection({
    super.key,
  });

  //final FavToggleState toggleState;

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
                //  context.read<FavToggleCubit>().toggle();
              },
              isSelected: false,
              // isSelected: toggleState is FavDoctors,
            ),
          ),
          Expanded(
            child: FavToggleItem(
              title: "حجوزاتي السابقة",
              onTap: () {
                //context.read<FavToggleCubit>().toggle();
              },
              isSelected: true,
              // isSelected: toggleState is FavArticles,
            ),
          ),
        ],
      ),
    );
  }
}
