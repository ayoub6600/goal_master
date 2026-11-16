import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/auth/data/services/onboarding_screens_service.dart';
import 'package:goal_master/features/onboarding/data/datasource/onboarding_pages.dart';
import 'package:goal_master/features/onboarding/data/model/onboarding_model.dart';
import 'package:goal_master/features/onboarding/presentation/manager/onboarding_cubit.dart';
import 'package:goal_master/features/onboarding/presentation/view/widgets/bottom_curve_clipper.dart';
import 'package:goal_master/features/onboarding/presentation/view/widgets/button_onbording.dart';
import 'package:goal_master/features/onboarding/presentation/view/widgets/onboarding_dots.dart';
import 'package:goal_master/features/onboarding/presentation/view/widgets/onboarding_next_page_button.dart';
import 'package:goal_master/features/onboarding/presentation/view/widgets/onboarding_previous_page_button.dart';

class OnboardingViewBody extends StatelessWidget {
  const OnboardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<OnboardingCubit>();
    // Rebuilds once the admin's slides arrive (usually already fetched
    // during the splash).
    return FutureBuilder<void>(
      future: OnboardingScreensService.instance.ensureLoaded(),
      builder: (context, _) => _buildBody(context, cubit),
    );
  }

  Widget _buildBody(BuildContext context, OnboardingCubit cubit) {
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
                              (e) => _IntroImage(page: e),
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

/// The admin's picture for a slide, falling back to the bundled one while it
/// loads or if there is none. Decoded at screen width, not at upload size.
class _IntroImage extends StatelessWidget {
  const _IntroImage({required this.page});

  final OnboardingModel page;

  @override
  Widget build(BuildContext context) {
    final bundled = Image.asset(
      page.images,
      width: double.infinity,
      fit: BoxFit.cover,
    );
    final url = page.imageUrl;
    if (url == null || url.isEmpty) return bundled;

    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      memCacheWidth: 1080,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, __) => bundled,
      errorWidget: (_, __, ___) => bundled,
    );
  }
}
