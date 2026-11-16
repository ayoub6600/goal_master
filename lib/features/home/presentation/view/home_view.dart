import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/should_execute.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/coin_burst_popup.dart';
import 'package:goal_master/features/home/presentation/manager/analysis_cubit/analysis_cubit.dart';
import 'package:goal_master/features/home/presentation/manager/get_services_info_cubit/get_services_info_cubit.dart';
import 'package:goal_master/features/home/presentation/view/widgets/build_header_home.dart';
import 'package:goal_master/features/home/presentation/view/widgets/build_location_row.dart';
import 'package:goal_master/features/home/presentation/view/widgets/list_section_play.dart';
import 'package:goal_master/features/home/presentation/view/widgets/services_info_view.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';
import 'package:goal_master/features/layout/presentation/view/widget/banner_carousel_view.dart';
import 'package:goal_master/features/games/presentation/moving_target_game.dart';
import 'package:goal_master/features/home/presentation/view/widgets/home_sections.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late LayoutCubit layoutCubit;

  @override
  void initState() {
    super.initState();
    layoutCubit = context.read<LayoutCubit>();
    // Show the last known location instantly (no waiting on GPS/permission)
    // while a fresh fix is requested in the background.
    layoutCubit.loadSavedLocation();
    layoutCubit.initUserLocation();
    context.read<CoinsCubit>().getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // Home follows the ACTIVE location, not the device's position.
            //
            // This used to listen to LayoutCubit.currentPosition — the raw GPS
            // fix — so the venue list moved whenever the handset did, quietly
            // overriding a location the customer had deliberately chosen. It
            // now reacts to the one thing that represents that choice.
            BlocListener<ActiveLocationCubit, ActiveLocationState>(
              listenWhen: (previous, current) =>
                  current.location != null &&
                  previous.location != current.location,
              listener: (context, state) {
                // No coordinates passed: the repository reads the Active
                // Location itself, so there is one path to the fact.
                context.read<GetServicesInfoCubit>().getServicesInfo();
              },
            ),
            BlocListener<CoinsCubit, CoinsState>(
              listenWhen: (previous, current) =>
                  current.justEarnedCoins != null,
              listener: (context, state) {
                final earned = state.justEarnedCoins;
                if (earned != null) {
                  showCoinBurstPopup(context, earned);
                  context.read<CoinsCubit>().clearJustEarned();
                }
              },
            ),
          ],
          child: BlocBuilder<LayoutCubit, LayoutState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  final servicesCubit = context.read<GetServicesInfoCubit>();
                  final analysisCubit = context.read<AnalysisCubit>();

                  // Pull-to-refresh reloads CONTENT, not the customer's
                  // location. It used to call getMyCurrentLocation(), which
                  // re-read GPS and silently moved anyone who had chosen a
                  // different city — a refresh that changes where you are is
                  // not a refresh.
                  await servicesCubit.getServicesInfo();
                  await analysisCubit.getAnalysis();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BuildHeaderHome(layoutCubit: layoutCubit),
                    const SizedBox(height: 10),
                    const BuildLocationRow(),
                    const SizedBox(height: 10),
                    HomeSearchBar(
                      onTap: () => shouldExecute(
                        context: context,
                        callback: () => push(RoutesKeys.kFilter, context),
                      ),
                    ),
                    HeightSpace(16.h),
                    HomeBookingHero(
                      onTap: () => push(RoutesKeys.kBookingDetails, context),
                    ),
                    HeightSpace(12.h),
                    const MovingTargetGameCard(),
                    HeightSpace(16.h),
                    BannerCarouselScreen(),
                    HeightSpace(20.h),
                    BlocBuilder<GetServicesInfoCubit, GetServicesInfoState>(
                      builder: (context, servicesState) {
                        final zoneName = servicesState is GetServicesInfoSuccess
                            ? servicesState.zoneName
                            : null;
                        return HomeSectionTitle(
                          'ملاعب قريبة منك',
                          note: (zoneName == null || zoneName.isEmpty)
                              ? null
                              : zoneName,
                        );
                      },
                    ),
                    HeightSpace(8.h),
                    SizedBox(height: 190.h, child: ServicesInfoView()),
                    HeightSpace(12.h),
                    const HomeSectionTitle('ملخص حجوزاتي'),
                    HeightSpace(10.h),
                    ListSectionPlay(),
                    HeightSpace(110.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
