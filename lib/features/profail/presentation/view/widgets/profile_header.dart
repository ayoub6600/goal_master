import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/profail/presentation/manager/profile_cubit/profile_cubit.dart';

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
          Image.asset(Assets.imagesPngImageProfailIcon),
          WidthSpace(16.w),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                print("state: $state");
                if (state is ProfileLoading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No Name",
                        style: AppTextStyles.font16SemiBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      HeightSpace(8.h),
                      Text(
                        "No Phone",
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
                    "Error: ${state.error}",
                    style: TextStyle(color: Colors.red),
                  );
                }
                return Text("No Data Available");
              },
            ),
          ),
        ],
      ),
    );
  }
}
