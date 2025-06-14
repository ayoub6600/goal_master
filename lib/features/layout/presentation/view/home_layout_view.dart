import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo_imp.dart';
import 'package:goal_master/features/balance/presentation/cubit/balance_cubit.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/cancel_booking_cubit/cancel_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/toggle_booking/booking_toggle_cubit.dart';

import 'package:goal_master/features/booking/presentation/view/booking_view.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';
import 'package:goal_master/features/home/data/repo/analysis_repo_imp.dart';
import 'package:goal_master/features/home/presentation/manager/analysis_cubit/analysis_cubit.dart';
import 'package:goal_master/features/home/presentation/manager/banner_cubit/banner_cubit_cubit.dart';
import 'package:goal_master/features/home/presentation/manager/get_services_info_cubit/get_services_info_cubit.dart';
import 'package:goal_master/features/home/presentation/view/home_view.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';
import 'package:goal_master/features/layout/presentation/view/widget/home_bottom_nav_bar.dart';
import 'package:goal_master/features/profile/presentation/view/profile_view.dart';

class HomeLayoutView extends StatefulWidget {
  const HomeLayoutView({super.key});

  @override
  State<HomeLayoutView> createState() => _HomeLayoutViewState();
}

class _HomeLayoutViewState extends State<HomeLayoutView> {
  late LayoutCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<LayoutCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return Stack(
            children: [
              if (state.activeScreen == NavBarElement.home)
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => AnalysisCubit(
                        getIt<AnalysisRepoImp>(),
                      )..getAnalysis(),
                    ),
                    //BannerCubitCubit
                    BlocProvider(
                      create: (context) => BannerCubitCubit(
                        getIt<AnalysisRepoImp>(),
                      )..getBanner(),
                    ),
                    //BalanceCubit
                    BlocProvider(
                      create: (context) => BalanceCubit(
                        getIt<BalanceRepoImp>(),
                      )..getBalance(),
                    ),
                    //GetServicesInfoCubit
                    BlocProvider(
                      create: (context) => GetServicesInfoCubit(
                        getIt<AnalysisRepoImp>(),
                      )..getServicesInfo(),
                    ),
                  ],
                  // create: (context) => AnalysisCubit(
                  //   getIt<AnalysisRepoImp>(),
                  // )..getAnalysis(),
                  child: const HomeView(),
                ),
              if (state.activeScreen == NavBarElement.booking)
                MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => BookingCubit(
                        bookingRepo: getIt<BookingRepoImp>(),
                      ),
                    ),
                    //CancelBookingCubit
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
              if (state.activeScreen == NavBarElement.profile)
                BlocProvider(
                  create: (context) => BalanceCubit(
                    getIt<BalanceRepoImp>(),
                  )..getBalance(),
                  child: const ProfileView(),
                ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: HomeBottomNavBar(
              //     changeElement: (screen) => cubit.changeSelectedNavBar(screen),
              //     activeElement: state.activeScreen,
              //   ),
              // ),
            ],
          );
        },
      ),

      // زر عائم في المنتصف
      floatingActionButton: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return SizedBox(
            width: 80.62.w,
            height: 80.62.h,
            child: FloatingActionButton(
              backgroundColor: Color(0xffF4F6F9),
              shape: const CircleBorder(),
              elevation: 5,
              onPressed: () => cubit.changeSelectedNavBar(NavBarElement.home),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    Assets.imagesPngImageHome,
                    color: state.activeScreen == NavBarElement.home
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  Text(
                    "الرئيسية",
                    style: TextStyle(
                      color: state.activeScreen == NavBarElement.home
                          ? AppColors.primary
                          : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // تحديد موقع الزر العائم
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // شريط التنقل السفلي مع قص الزر العائم
      bottomNavigationBar: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return HomeBottomNavBar(
            changeElement: (screen) => cubit.changeSelectedNavBar(screen),
            activeElement: state.activeScreen,
          );
        },
      ),
    );
  }
}
