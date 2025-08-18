import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/profile/presentation/manager/profile_cubit/profile_cubit.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      color: Color(0xffDFF5E1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Assets.imagesPngImageSoccerPlayer,
            width: 50.w,
            height: 50.h,
            fit: BoxFit.cover,
          ),
          WidthSpace(16.w),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SharedPreferenceUtil.getString(PrefKey.fullName),
                        style: AppTextStyles.font16SemiBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      HeightSpace(8.h),
                      Text(
                        SharedPreferenceUtil.getString(PrefKey.phone),
                        style: AppTextStyles.font16SemiBold
                            .copyWith(color: Color(0xff6D7580)),
                      ),
                    ],
                  );
                } else if (state is ProfileLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.user.name ?? "No Name",
                        style: AppTextStyles.font16SemiBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      HeightSpace(8.h),
                      Text(
                        state.user.phoneNumber ?? "No Phone",
                        style: AppTextStyles.font16SemiBold
                            .copyWith(color: Color(0xff6D7580)),
                      ),
                    ],
                  );
                } else if (state is ProfileError) {
                  return Text(
                    " ${state.error}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.red),
                  );
                }
                return Text("No Data Available");
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "رصيد المحفظة",
                style: AppTextStyles.font12SemiBold
                    .copyWith(color: Color(0xff6D7580)),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await push(RoutesKeys.kCard, context);
                  // لو الشاشة رجّعت true (بعد شحن/تحويل)، حدّث الرصيد هنا
                  if (result == true) {
                    context.read<BalanceCubit>().getBalance();
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: BlocBuilder<BalanceCubit, BalanceState>(
                    builder: (context, state) {
                      if (state is BalanceLoading) {
                        return Text(
                          "...",
                          style: AppTextStyles.font16SemiBold,
                        );
                      } else if (state is BalanceLoaded) {
                        return Center(
                          child: Column(
                            children: [
                              Text(
                                state.balance.toString(),
                                style: AppTextStyles.font16SemiBold,
                              ),
                              Text(
                                "دينار",
                                style: AppTextStyles.font16SemiBold,
                              ),
                            ],
                          ),
                        );
                      } else if (state is BalanceError) {
                        return Center(
                          child: SizedBox(
                            width: 50.w,
                            child: Text(
                              " ${state.errMessage}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }
                      return Center(child: Text("No Data"));
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
