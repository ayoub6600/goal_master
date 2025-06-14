import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_wrapper.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/onboarding/data/datasource/onboarding_pages.dart';
import 'package:goal_master/features/onboarding/presentation/manager/onboarding_cubit.dart';

class OnboardingSkipPageButton extends StatelessWidget {
  const OnboardingSkipPageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<OnboardingCubit>();
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        bool isLastPage =
            state.index == OnboardingPages.getPages(context).length - 1;
        return ButtonWrapper(
            onTap: () {
              bool done = cubit.increment(context);
              if (!done) {
                pushReplacement(RoutesKeys.kRegister, context);
                SharedPreferenceUtil.putString(PrefKey.login, "true");
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                //  color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  width: 1,
                  color: isLastPage ? AppColors.black : Colors.white,
                ),
              ),
              child: Text(
                isLastPage ? "انشاء حساب" : "تخطى",
                style: AppTextStyles.font16Regular.copyWith(
                  color: Colors.black,
                ),
              ),
            ));
      },
    );
  }
}
