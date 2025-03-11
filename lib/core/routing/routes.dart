import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/components/build_page_with_default_transition.dart';
import 'package:goal_master/core/routing/routes_branches.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/features/auth/presentation/view/forgot_password_view.dart';
import 'package:goal_master/features/auth/presentation/view/new_password_view.dart';
import 'package:goal_master/features/auth/presentation/view/otp_view.dart';
import 'package:goal_master/features/auth/presentation/view/register_view.dart';
import 'package:goal_master/features/auth/presentation/view/login_view.dart';
import 'package:goal_master/features/onbording/presentation/manager/onboarding_cubit.dart';
import 'package:goal_master/features/onbording/presentation/view/onboarding_view.dart';
import 'package:goal_master/features/profail/presentation/view/profile_view.dart';
import 'package:goal_master/features/splach/presentation/view/splash_view.dart';

import 'app_router.dart';

List<RouteBase> appRoutes = [
  // StatefulShellRoute.indexedStack(
  //   builder: (context, state, navigationShell) {
  //     return MainNavigationBar(navigationShell: navigationShell);
  //   },
  //   branches: routesBranches,
  // ),
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kSplashView,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const SplashView(),
    ),
  ),
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kOnboarding,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => OnboardingCubit(),
        child: const OnboardingView(),
      ),
    ),
  ),
  //kLogin
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kLogin,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const LoginView(),
    ),
  ),
  //RegisterView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kRegister,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const RegisterView(),
    ),
  ),
  //ForgotPasswordView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kForgotPassword,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const ForgotPasswordView(),
    ),
  ),
  //OtpView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kOtp,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const OtpView(),
    ),
  ),
  //NewPasswordView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kNewPassword,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const NewPasswordView(),
    ),
  ),
  //ProfileView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kProfile,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const ProfileView(),
    ),
  ),
];
