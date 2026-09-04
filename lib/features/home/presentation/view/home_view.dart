import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late LayoutCubit layoutCubit;
  List<String> _emojis = ['⚽', '🏀', '🎾', '🏐'];
  int _emojiIndex = 0;
  late Timer _emojiTimer;
  String get _currentEmoji => _emojis[_emojiIndex];

  @override
  void initState() {
    super.initState();
    layoutCubit = context.read<LayoutCubit>();
    // Show the last known location instantly (no waiting on GPS/permission)
    // while a fresh fix is requested in the background.
    layoutCubit.loadSavedLocation();
    layoutCubit.initUserLocation();
    context.read<CoinsCubit>().getBalance();
    _emojiTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _emojiIndex = (_emojiIndex + 1) % _emojis.length;
      });
    });
  }

  @override
  void dispose() {
    _emojiTimer.cancel();
    super.dispose();
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
              listenWhen: (previous, current) => current.justEarnedCoins != null,
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          shouldExecute(
                            context: context,
                            callback: () async {
                              push(RoutesKeys.kFilter, context);
                            },
                          );
                        },
                        child: Container(
                            width: 300.w,
                            height: 40.h,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xffDADEE3),
                                )),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "ابحث",
                                    style: AppTextStyles.font14Medium
                                        .copyWith(color: AppColors.fontColor),
                                  ),
                                  Image.asset(
                                    Assets.imagesPngImageSearchNormal,
                                  )
                                ])),
                      ),
                      WidthSpace(8.w),
                      GestureDetector(
                        onTap: () {
                          shouldExecute(
                            context: context,
                            callback: () async {
                              push(RoutesKeys.kFilter, context);
                            },
                          );
                        },
                        child: Image.asset(
                          Assets.imagesPngImageFiltter,
                          //   color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BannerCarouselScreen(),
                  HeightSpace(20.h),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.1),
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 70, 189, 118)
                                  .withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOut,
                              width:
                                  MediaQuery.of(context).size.width * 0.3 + 20,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(255, 92, 174, 132)
                                            .withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                            ButtonApp(
                              text: "احجز الآن $_currentEmoji",
                              onTap: () {
                                push(RoutesKeys.kBookingDetails, context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    onEnd: () {
                      setState(() {
                        _emojiIndex = (_emojiIndex + 1) % _emojis.length;
                      });
                    },
                  ),
                  HeightSpace(24.h),
                  BlocBuilder<GetServicesInfoCubit, GetServicesInfoState>(
                    builder: (context, servicesState) {
                      final zoneName = servicesState is GetServicesInfoSuccess
                          ? servicesState.zoneName
                          : null;
                      if (zoneName == null || zoneName.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "الملاعب المتاحة في منطقتك: $zoneName",
                          style: AppTextStyles.font14Medium
                              .copyWith(color: AppColors.primary),
                        ),
                      );
                    },
                  ),
                  HeightSpace(8.h),
                  SizedBox(height: 200.h, child: ServicesInfoView()),
                  HeightSpace(8.h),
                  ListSectionPlay(),
                  HeightSpace(24.h),
                  HeightSpace(100.h),
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
