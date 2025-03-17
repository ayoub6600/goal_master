import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/more/presentation/view/more_view.dart';

class BuildHeaderHome extends StatelessWidget {
  const BuildHeaderHome({super.key, required this.layoutCubit});

  final LayoutCubit layoutCubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            icon: Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MoreView();
              }));
            }),
        Expanded(
          child: Row(
            children: [
              Text(
                'مرحبًا بك ',
                style: AppTextStyles.font16Medium
                    .copyWith(color: AppColors.fontColor),
              ),
              Text(
                ', احمد',
                style:
                    AppTextStyles.font16Bold.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Image.asset(Assets.imagesPngImageNotification),
        ),
      ],
    );
  }
}
