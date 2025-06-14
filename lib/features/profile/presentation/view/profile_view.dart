import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo_imp.dart';
import 'package:goal_master/features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:goal_master/features/profile/presentation/view/widgets/profile_header.dart';
import 'package:goal_master/features/profile/presentation/view/widgets/profile_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        getIt.get<ProfileRepoImp>(),
      )..getProfile(),
      child: PageWrapper(
        title: "حسابي",
        allowBack: false,
        child: Column(
          children: [
            ProfileHeader(),
            HeightSpace(16.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  //  spacing: 16.h,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          Assets.imagesPngImageSetting2,
                          fit: BoxFit.cover,
                        ),
                        WidthSpace(16.w),
                        Text(
                          "اعدادات عامة",
                          style: AppTextStyles.font16Bold.copyWith(
                            color: AppColors.fontColor,
                          ),
                        ),
                      ],
                    ),
                    HeightSpace(8.h),
                    ProfileItem(
                      title: "تغيير معلوماتك الشخصية",
                      icon: Assets.imagesPngImageMagicpen,
                      onTap: () async {
                        final result =
                            await push(RoutesKeys.kUpdateProfile, context);

                        if (result == true) {
                          context.read<ProfileCubit>().getProfile();
                        }
                      },
                    ),
                    Container(
                      width: double.infinity,
                      color: Color(0xffDADEE3),
                      height: 1.h,
                    ),
                    HeightSpace(8.h),
                    ProfileItem(
                      title: "شحن الرصيد",
                      icon: Assets.imagesPngImageWallet2,
                      onTap: () {
                        push(RoutesKeys.kCard, context);
                      },
                    ),
                    Container(
                      width: double.infinity,
                      color: Color(0xffDADEE3),
                      height: 1.h,
                    ),
                    HeightSpace(8.h),
                    ProfileItem(
                      title: "تغيير كلمة المرور",
                      icon: Assets.imagesPngImageKey,
                      onTap: () {
                        push(RoutesKeys.kChangePassword, context);
                      },
                    ),
                    Container(
                      width: double.infinity,
                      color: Color(0xffDADEE3),
                      height: 1.h,
                    ),
                    HeightSpace(8.h),
                    ProfileItem(
                      title: "اتصل بنا",
                      icon: Assets.imagesPngImageCallCalling,
                      onTap: () {
                        push(RoutesKeys.kContact, context);
                      },
                    ),
                    Container(
                      width: double.infinity,
                      color: Color(0xffDADEE3),
                      height: 1.h,
                    ),
                    HeightSpace(8.h),
                    ProfileItem(
                      title: "خروج",
                      icon: Assets.imagesPngImageLogout,
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "تسجيل الخروج",
                                    style: AppTextStyles.font16Bold,
                                  ),
                                  HeightSpace(16.h),
                                  Text(
                                    "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                                    style: AppTextStyles.font14Medium.copyWith(
                                      color: AppColors.fontColor,
                                    ),
                                  ),
                                  HeightSpace(16.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ButtonApp(
                                            text: "تسجيل الخروج",
                                            onTap: () async {
                                              Navigator.pop(
                                                  context); // Close the sheet
                                              await SharedPreferenceUtil
                                                  .clear();
                                              pushReplacement(
                                                  RoutesKeys.kLogin, context);
                                              SharedPreferenceUtil.putString(
                                                  PrefKey.login, "true");
                                            }),
                                      ),
                                      WidthSpace(16.w),
                                      Expanded(
                                        child: ButtonApp(
                                            textColor: Colors.white,
                                            backGround: Colors.red,
                                            text: "الغاء",
                                            onTap: () {
                                              Navigator.pop(
                                                  context); // Close the sheet
                                            }),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: SizedBox(),
                    ),
                    Container(
                      width: double.infinity,
                      color: Color(0xffDADEE3),
                      height: 1.h,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
