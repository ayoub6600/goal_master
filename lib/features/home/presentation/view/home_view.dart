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
import 'package:goal_master/features/home/presentation/view/widgets/build_header_home.dart';
import 'package:goal_master/features/home/presentation/view/widgets/build_location_row.dart';
import 'package:goal_master/features/home/presentation/view/widgets/list_section_play.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';

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
    if (layoutCubit.state.isUpdate) {
      layoutCubit.changeIsUpdate(false);
      layoutCubit.initUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LayoutCubit, LayoutState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                layoutCubit.initUserLocation();
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
                          push(RoutesKeys.kFilter, context);
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
                          push(RoutesKeys.kFilter, context);
                        },
                        child: Image.asset(
                          Assets.imagesPngImageFiltter,
                          //   color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  //carousel_slider
                  Container(
                    // width: double.infinity,
                    height: 180.h,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(Assets.imagesPngImageHomeTest),
                    )),
                  ),
                  HeightSpace(20.h),

                  ButtonApp(
                      text: " احجز الان",
                      onTap: () {
                        push(RoutesKeys.kBookingDetails, context);
                      }),

                  HeightSpace(24.h),

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
    );
  }
}
