import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/components/build_page_with_default_transition.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/view/no_internet_view.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';
import 'package:goal_master/features/auth/presentation/manager/change_password_cubit/change_password_cubit.dart';
import 'package:goal_master/features/auth/presentation/manager/login_cubit/login_cubit.dart';
import 'package:goal_master/features/auth/presentation/manager/register_cubit/register_cubit.dart';
import 'package:goal_master/features/auth/presentation/manager/verify_email_cubit/verify_email_cubit.dart';
import 'package:goal_master/features/auth/presentation/view/forgot_password_view.dart';
import 'package:goal_master/features/auth/presentation/view/new_password_view.dart';
import 'package:goal_master/features/auth/presentation/view/otp_view.dart';
import 'package:goal_master/features/auth/presentation/view/register_view.dart';
import 'package:goal_master/features/auth/presentation/view/login_view.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/cancel_booking_cubit/cancel_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/service_cubit/service_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/toggle_booking/booking_toggle_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/zone_cubit/zone_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/booking_details.dart';
import 'package:goal_master/features/booking/presentation/view/booking_items_details.dart.dart';
import 'package:goal_master/features/booking/presentation/view/booking_view.dart';
import 'package:goal_master/features/card/data/repo/card_repo_imp.dart';
import 'package:goal_master/features/card/presentation/manager/cubit/card_cubit.dart';
import 'package:goal_master/features/card/presentation/view/card_view.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo_imp.dart';
import 'package:goal_master/features/home/presentation/manager/filter_cubit/filter_cubit.dart';
import 'package:goal_master/features/home/presentation/manager/page_view_new_booking_cubit/page_view_new_booking_cubit.dart';
import 'package:goal_master/features/home/presentation/view/fillter_view.dart';
import 'package:goal_master/features/home/presentation/view/widgets/booking_item.dart';
import 'package:goal_master/features/home/presentation/view/widgets/show_all_resulat_filtter.dart';
import 'package:goal_master/features/layout/presentation/view/home_layout_view.dart';
import 'package:goal_master/features/notification/presentation/view/notifaction_view.dart';
import 'package:goal_master/features/onboarding/presentation/manager/onboarding_cubit.dart';
import 'package:goal_master/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo_imp.dart';
import 'package:goal_master/features/profile/presentation/manager/reset_password_cubit/reset_password_cubit.dart';
import 'package:goal_master/features/profile/presentation/manager/update_profile_cubit/update_profile_cubit.dart';
import 'package:goal_master/features/profile/presentation/view/change_password_view.dart';
import 'package:goal_master/features/profile/presentation/view/contact_view.dart';
import 'package:goal_master/features/profile/presentation/view/profile_view.dart';
import 'package:goal_master/features/profile/presentation/view/update_profile_view.dart';
import 'package:goal_master/features/splash/presentation/view/splash_view.dart';

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
  //kNoInternet
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kNoInternet,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const NoInternetView(),
    ),
  ),
  //kLogin
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kLogin,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => LoginCubit(getIt<AuthRepoImpl>()),
        child: const LoginView(),
      ),
    ),
  ),
  //RegisterView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kRegister,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => RegisterCubit(
          getIt<AuthRepoImpl>(),
        ),
        child: const RegisterView(),
      ),
    ),
  ),
  //ForgotPasswordView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kForgotPassword,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => VerifyEmailCubit(
          getIt<AuthRepoImpl>(),
          '',
          forget: true,
        ),
        child: const ForgotPasswordView(),
      ),
    ),
  ),

  //OtpView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kOtp,
    pageBuilder: (context, state) {
      final Map<String, dynamic> extraData =
          state.extra as Map<String, dynamic>;
      final phone = extraData['phone'] as String;
      final forget = extraData['forget'] as bool;

      return buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => VerifyEmailCubit(
            getIt<AuthRepoImpl>(),
            phone,
            forget: forget,
          ),
          child: const OtpView(),
        ),
      );
    },
  ),
  //NewPasswordView
  GoRoute(
      parentNavigatorKey: parentKey,
      path: RoutesKeys.kNewPassword,
      pageBuilder: (context, state) {
        return buildPageWithDefaultTransition<void>(
          context: context,
          state: state,
          child: BlocProvider(
            create: (context) => ChangePasswordCubit(
              getIt<AuthRepoImpl>(),
              state.extra as String,
            ),
            child: const NewPasswordView(),
          ),
        );
      }),
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
  //UpdateProfileView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kUpdateProfile,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => UpdateProfileCubit(
          getIt<ProfileRepoImp>(),
        ),
        child: const UpdateProfileView(),
      ),
    ),
  ),
  //ChangePasswordView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kChangePassword,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => ResetPasswordCubit(
          getIt<ProfileRepoImp>(),
        ),
        child: const ChangePasswordView(),
      ),
    ),
  ),
  //ContactView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kContact,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const ContactView(),
    ),
  ),
  //BookingView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kBooking,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => BookingCubit(
              bookingRepo: getIt<BookingRepoImp>(),
            ),
          ),
          BlocProvider(
            create: (context) => CancelBookingCubit(
              getIt<BookingRepoImp>(),
            ),
          ),
          BlocProvider(
            create: (context) => ToggleCubit(),
          ),
        ],
        child: const BookingView(),
      ),
    ),
  ),
  //BookingDetails
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kBookingDetails,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ZoneCubitCubit(
              getIt<BookingRepoImp>(),
            )..listZone(),
          ),
          //ClubCubit
          BlocProvider(
              create: (context) => ClubCubit(
                    getIt<BookingRepoImp>(),
                  )),
          //CategoryCubit
          BlocProvider(
              create: (context) => CategoryCubit(
                    getIt<BookingRepoImp>(),
                  )),
          //ServiceCubit
          BlocProvider(
              create: (context) => ServiceCubit(
                    getIt<BookingRepoImp>(),
                  )),
          //EmployeeCubit
          BlocProvider(
            create: (context) => EmployeeCubit(
              getIt<BookingRepoImp>(),
            ),
          ),
          //AddBookingCubit
          BlocProvider(
            create: (context) => AddBookingCubit(
              getIt<BookingRepoImp>(),
            ),
          ),
          BlocProvider(
            create: (context) => CalendarCubit(
              getIt<BookingRepoImp>(),
            ),
          ),
          BlocProvider(
            create: (context) => PageViewCubit(),
          ),
        ],
        child: const BookingDetails(),
      ),
    ),
  ),

//AddNewBooking
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kAddNewBooking,
    pageBuilder: (context, state) {
      final booking = state.extra as BookingSlot;

      return buildPageWithDefaultTransition<void>(
        context: context,
        state: state,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => EmployeeCubit(getIt<BookingRepoImp>()),
            ),
            BlocProvider(
              create: (context) => AddBookingCubit(getIt<BookingRepoImp>()),
            ),
            BlocProvider(
              create: (context) => PageViewNewBookingCubit(),
            ),
          ],
          child: AddNewBooking(booking: booking), // ✅ pass the booking here
        ),
      );
    },
  ),

  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kHome,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: const HomeLayoutView(),
    ),
  ),
  //CardView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kCard,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => CardCubit(
          getIt<CardRepoImp>(),
        ),
        child: const CardView(),
      ),
    ),
  ),
  //NotificationView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kNotification,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => BookingCubit(
          bookingRepo: getIt<BookingRepoImp>(),
        ),
        child: const NotificationView(),
      ),
    ),
  ),
  //BookingItemsDetails
  GoRoute(
      parentNavigatorKey: parentKey,
      path: RoutesKeys.kBookingItemsDetails,
      pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => BookingCubit(
                bookingRepo: getIt<BookingRepoImp>(),
              ),
              child: BookingItemsDetails(
                booking: state.extra as Booking,
              ),
            ),
          )),
  //FilterView
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kFilter,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ZoneCubitCubit(
              getIt<BookingRepoImp>(),
            )..listZone(),
          ),
          //ClubCubit
          BlocProvider(
              create: (context) => ClubCubit(
                    getIt<BookingRepoImp>(),
                  )),
          //CategoryCubit
          BlocProvider(
              create: (context) => CategoryCubit(
                    getIt<BookingRepoImp>(),
                  )),
          //FilterCubit
          BlocProvider(
            create: (context) => FilterCubit(
              getIt<AnalysisRepoImp>(),
            ),
          ),
        ],
        child: const FilterView(),
      ),
    ),
  ),
  //kShowAllResulatFiltter
  GoRoute(
    parentNavigatorKey: parentKey,
    path: RoutesKeys.kShowAllResulatFiltter,
    pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => FilterCubit(
          getIt<AnalysisRepoImp>(),
        ),
        child: ShowAllResulatFiltter(),
      ),
    ),
  ),
];
