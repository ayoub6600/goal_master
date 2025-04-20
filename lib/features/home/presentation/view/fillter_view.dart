import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_date_picker.dart';
import 'package:goal_master/core/components/custom_drop_down.dart';
import 'package:goal_master/core/components/custom_drop_down_shimmer.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_time_picker.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/zone_cubit/zone_cubit.dart';
import 'package:goal_master/features/home/presentation/manager/filter_cubit/filter_cubit.dart';
import 'package:goal_master/features/home/presentation/view/widgets/show_all_resulat_filtter.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  bool isSearchVisible = true; // متغير للتحكم في ظهور جزء البحث

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      allowBack: true,
      title: 'البحث',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Visibility(
              visible: isSearchVisible,
              child: Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeightSpace(20.h),
                      Text(
                        "تاريخ الحجز",
                        style: AppTextStyles.font16Bold,
                      ),
                      HeightSpace(8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "من",
                                  style: AppTextStyles.font14Medium,
                                ),
                                HeightSpace(8.h),
                                CustomDatePicker(
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 30)),
                                  onDatePicked: (value) => context
                                      .read<FilterCubit>()
                                      .updateBookingStart(value.toString()),
                                ),
                              ],
                            ),
                          ),
                          WidthSpace(16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "الى",
                                  style: AppTextStyles.font14Medium,
                                ),
                                HeightSpace(8.h),
                                CustomDatePicker(
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 30)),
                                  onDatePicked: (value) => context
                                      .read<FilterCubit>()
                                      .updateBookingEnd(value.toString()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      HeightSpace(20.h),
                      Text(
                        "مدة الحجز",
                        style: AppTextStyles.font16Bold,
                      ),
                      HeightSpace(8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "من",
                                  style: AppTextStyles.font14Medium,
                                ),
                                HeightSpace(8.h),
                                CustomTimePicker(
                                  onTimePicked: (value) {
                                    if (value != null) {
                                      final hours =
                                          value.hour.toString().padLeft(2, '0');
                                      final minutes = value.minute
                                          .toString()
                                          .padLeft(2, '0');
                                      final formattedTime24 =
                                          "$hours:$minutes:00"; // مثال: "02:28:00"

                                      context
                                          .read<FilterCubit>()
                                          .updateStartTime(formattedTime24);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          WidthSpace(16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "الى",
                                  style: AppTextStyles.font14Medium,
                                ),
                                HeightSpace(8.h),
                                CustomTimePicker(
                                  onTimePicked: (value) {
                                    if (value != null) {
                                      // تحويل TimeOfDay إلى String بالتنسيق المطلوب
                                      final hours =
                                          value.hour.toString().padLeft(2, '0');
                                      final minutes = value.minute
                                          .toString()
                                          .padLeft(2, '0');
                                      final formattedTime24 =
                                          "$hours:$minutes:00"; // مثال: "22:00:00"

                                      // تمرير الوقت بالتنسيق الجديد إلى updateEndTime
                                      context
                                          .read<FilterCubit>()
                                          .updateEndTime(formattedTime24);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      HeightSpace(20.h),
                      BlocBuilder<ZoneCubitCubit, ZoneCubitState>(
                        builder: (context, state) {
                          if (state is ZoneCubitLoading) {
                            return CustomDropDownShimmer(
                              label: "اختر المنطقة",
                              hint: "اختر المنطقة",
                            );
                          } else if (state is ZoneCubitError) {
                            return const SizedBox(); // Or show an error widget
                          } else if (state is ZoneCubitSuccess) {
                            final locations = state.location;
                            return CustomDropdown(
                              hint: "اختر المنطقة",
                              items:
                                  locations.map((zone) => zone.name).toList(),
                              onChanged: (value) {
                                final selectedZone = locations
                                    .firstWhere((zone) => zone.name == value);

                                context
                                    .read<ClubCubit>()
                                    .listClub(selectedZone.id);
                              },
                            );
                          }
                          return const SizedBox(); // default for ZoneCubitInitial or unexpected states
                        },
                      ),
                      BlocBuilder<ClubCubit, ClubState>(
                        builder: (context, state) {
                          if (state is ClubLoading) {
                            return CustomDropDownShimmer(
                              label: "اختر النادي",
                              hint: "اختر النادي",
                            );
                          } else if (state is ClubError) {
                            return const SizedBox(); // Or show an error widget
                          } else if (state is ClubSuccess) {
                            final clubs = state.clubs;
                            return CustomDropdown(
                              hint: "اختر النادي",
                              items: clubs.map((zone) => zone.name).toList(),
                              onChanged: (value) {
                                final selected =
                                    clubs.firstWhere((c) => c.name == value);
                                context
                                    .read<FilterCubit>()
                                    .updateBranchId(selected.id.toString());

                                context.read<CategoryCubit>().listCategory(
                                      branchId: clubs
                                          .firstWhere(
                                              (zone) => zone.name == value)
                                          .id, // استخدم ID الخاص بالفرع
                                    );
                              },
                            );
                          }
                          return const SizedBox(); // default for ZoneCubitInitial or unexpected states
                        },
                      ),
                      BlocBuilder<CategoryCubit, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return CustomDropDownShimmer(
                              label: "اختر الفئة",
                              hint: "اختر الفئة",
                            );
                          } else if (state is CategoryFailure) {
                            return const SizedBox(); // Or show an error widget
                          } else if (state is CategorySuccess) {
                            final categories = state.categories;
                            return CustomDropdown(
                              hint: "اختر الفئة",
                              items:
                                  categories.map((zone) => zone.name).toList(),
                              onChanged: (value) {
                                final selected = categories
                                    .firstWhere((c) => c.name == value);
                                context
                                    .read<FilterCubit>()
                                    .updateCategoryId(selected.id.toString());
                              },
                            );
                          }
                          return const SizedBox(); // default for ZoneCubitInitial or unexpected states
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            HeightSpace(10.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 0.5.h,
                    color: AppColors.fontColor,
                  ),
                ),
                WidthSpace(10.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isSearchVisible = !isSearchVisible; // تغيير حالة البحث
                    });
                  },
                  child: Icon(
                    isSearchVisible ? Icons.arrow_upward : Icons.arrow_downward,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            HeightSpace(10.h),
            Expanded(
              flex: 1,
              child: BlocConsumer<FilterCubit, FilterState>(
                listener: (context, state) {
                  if (state is FilterError) {
                    showCustomFailureToast(state.message);
                  }
                },
                builder: (context, state) {
                  if (state is FilterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FilterLoaded) {
                    final bookings = state.filter.data;
                    return state.filter.data.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "النتائج ",
                                      style: AppTextStyles.font18Bold,
                                    ),
                                  ],
                                ),
                                HeightSpace(12.h),
                                Expanded(child: ShowAllResulatFiltter()),
                              ])
                        : const Center(child: Text("لا يوجد نتائج"));
                  }
                  return const SizedBox();
                },
              ),
            ),
            BlocConsumer<FilterCubit, FilterState>(
              listener: (context, state) {
                if (state is FilterError) {
                  print("error ${state.message}");
                  showCustomFailureToast(state.message);
                }
              },
              builder: (context, state) {
                return ButtonApp(
                  text: state is FilterLoading ? "جاري البحث..." : "بحث",
                  onTap: () => context.read<FilterCubit>().filterBooking(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
