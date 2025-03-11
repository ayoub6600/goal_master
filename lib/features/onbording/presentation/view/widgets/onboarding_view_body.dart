import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/onbording/data/datasource/onboarding_pages.dart';
import 'package:goal_master/features/onbording/presentation/manager/onboarding_cubit.dart';
import 'package:goal_master/features/onbording/presentation/view/widgets/bottom_curve_clipper.dart';
import 'package:goal_master/features/onbording/presentation/view/widgets/button_onbording.dart';
import 'package:goal_master/features/onbording/presentation/view/widgets/onboarding_dots.dart';
import 'package:goal_master/features/onbording/presentation/view/widgets/onboarding_next_page_button.dart';
import 'package:goal_master/features/onbording/presentation/view/widgets/onboarding_previous_page_button.dart';

class OnboardingViewBody extends StatelessWidget {
  const OnboardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<OnboardingCubit>();
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipPath(
                        clipper: BottomCurveClipper(),
                        child: PageView(
                          onPageChanged: (value) {
                            cubit.changeIndex(value);
                          },
                          controller: cubit.pageController,
                          children: [
                            ...OnboardingPages.getPages(context).map(
                              (e) => Image.asset(
                                e.images,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OnboardingDots(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 50.h,
                        right: 20.w,
                        child: OnboardingPreviousPageButtonIcon()),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      HeightSpace(50.h),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                    OnboardingPages.getPages(
                                            context)[state.index]
                                        .title,
                                    style: AppTextStyles.font24Bold.copyWith(
                                      color: Colors.black,
                                    )),
                                HeightSpace(16.h),
                                Center(
                                  child: Text(
                                      OnboardingPages.getPages(
                                              context)[state.index]
                                          .subtitle,
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: AppTextStyles.font18Bold.copyWith(
                                        color: Colors.black,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      HeightSpace(8.h),
                      OnboardingPreviousPageButton(),
                      HeightSpace(8.h),
                      OnboardingSkipPageButton(),
                      HeightSpace(30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
