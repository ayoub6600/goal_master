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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MoreView(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // من اليمين
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            }),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا بك يا',
                style: AppTextStyles.font12Medium.copyWith(color: AppColors.fontColor),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    '${SharedPreferenceUtil.getString(PrefKey.fullName)}',
                    style: AppTextStyles.font16Bold.copyWith(color: AppColors.primary),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '👋',
                    style: AppTextStyles.font20Bold.copyWith(color: AppColors.primary),
                  ),
                ],
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
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.balance.toString(),
                              style: AppTextStyles.font16SemiBold.copyWith(color: AppColors.primary),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "دينار",
                              style: AppTextStyles.font12SemiBold.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -20,
                        left: 8.w,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
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
