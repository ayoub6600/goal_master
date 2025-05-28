import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/balance/presentation/cubit/balance_cubit.dart';
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
                ', ${SharedPreferenceUtil.getString(PrefKey.fullName)}',
                style:
                    AppTextStyles.font16Bold.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            push(RoutesKeys.kCard, context);
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(18.w),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: BlocBuilder<BalanceCubit, BalanceState>(
              builder: (context, state) {
                if (state is BalanceLoading) {
                  return Text(
                    "...",
                    style: AppTextStyles.font16SemiBold,
                  );
                } else if (state is BalanceLoaded) {
                  return Center(
                    child: Row(
                      children: [
                        Text(
                          state.balance.toString(),
                          style: AppTextStyles.font16SemiBold,
                        ),
                        Text(
                          "دينار",
                          style: AppTextStyles.font12SemiBold,
                        ),
                      ],
                    ),
                  );
                } else if (state is BalanceError) {
                  return Center(
                    child: Text(
                      "Error: ${state.errMessage}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Center(child: Text("No Data"));
              },
            ),
          ),
        ),
        WidthSpace(10.w),
        // GestureDetector(
        //   onTap: () {
        //     push(RoutesKeys.kCard, context);
        //   },
        //   child: Image.asset(
        //     Assets.imagesPngImageWallet2,
        //     fit: BoxFit.cover,
        //     color: AppColors.primary,
        //     width: 25,
        //     height: 25,
        //   ),
        // ),
        // const SizedBox(
        //   width: 10,
        // ),

        GestureDetector(
          onTap: () {
            push(RoutesKeys.kNotification, context);
          },
          child: Image.asset(Assets.imagesPngImageNotification),
        ),

        //push(RoutesKeys.kCard, context);
      ],
    );
  }
}
