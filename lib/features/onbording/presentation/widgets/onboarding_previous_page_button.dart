import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_wrapper.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/onbording/manager/onboarding_cubit.dart';

class OnboardingPreviousPageButtonIcon extends StatelessWidget {
  const OnboardingPreviousPageButtonIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<OnboardingCubit>();
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        return ButtonWrapper(
            onTap: () {
              bool done = cubit.increment(context);
              if (!done) {
                // AppRouter.pushReplacement(context, LoginScreen());
                //   GoRouter.of(context).pushReplacement(RoutesKeys.kLogin);
              }
            },
            width: 48.w,
            height: 48.h,
            child: Image.asset(
              Assets.imagesPngImageArrowSquareRight,
            ));
      },
    );
  }
}
