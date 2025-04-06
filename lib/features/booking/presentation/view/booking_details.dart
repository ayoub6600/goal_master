import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_calder.dart';
import 'package:goal_master/core/components/custom_drop_down.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/zone_cubit/zone_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/booking_items_details.dart.dart';

class BookingDetails extends StatelessWidget {
  const BookingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "اضافة الحجز",
      allowBack: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeightSpace(16.h),
                  BlocBuilder<ZoneCubitCubit, ZoneCubitState>(
                    builder: (context, state) {
                      print("state: $state");
                      if (state is ZoneCubitLoading) {
                        return CustomDropdown(
                          hint: "اختر الموقع",
                          items: [], // تأكد من أن `zone.name` هو النص المناسب
                          onChanged: (value) {
                            // قم بإجراء العمليات المطلوبة بعد تغيير القيمة
                            // على سبيل المثال، إرسال القيمة إلى الـ Cubit أو غيرها
                            //     print("الملعب المختار: $value");
                          },
                        );
                      } else if (state is ZoneCubitError) {
                        print("error: ${state.message}");
                        return Center(child: Text('خطأ: ${state.message}'));
                      } else if (state is ZoneCubitSuccess) {
                        final zones = state.location;

                        return CustomDropdown(
                          hint: "اختر الموقع",
                          items: zones.map((zone) => zone.name).toList(),
                          onChanged: (value) {
                            print("الملعب المختار: $value");
                          },
                        );
                      }
                      return Center(child: Text('لا يوجد بيانات لعرضها.'));
                    },
                  ),
                  HeightSpace(16.h),
                  BlocBuilder<ClubCubit, ClubState>(
                    builder: (context, state) {
                      print("state: $state");
                      if (state is ClubLoading) {
                        return CustomDropdown(
                          hint: "اختر الملعب",
                          items: [], // تأكد من أن `zone.name` هو النص المناسب
                          onChanged: (value) {
                            // قم بإجراء العمليات المطلوبة بعد تغيير القيمة
                            // على سبيل المثال، إرسال القيمة إلى الـ Cubit أو غيرها
                            print("الملعب المختار: $value");
                          },
                        );
                      } else if (state is ClubError) {
                        print("error: ${state.message}");
                        return Center(child: Text('خطأ: ${state.message}'));
                      } else if (state is ClubSuccess) {
                        final clubs = state.clubs;

                        return CustomDropdown(
                          hint: "اختر الملعب",
                          items: clubs.map((zone) => zone.name).toList(),
                          onChanged: (value) {
                            print("الملعب المختار: $value");
                          },
                        );
                      }
                      return Center(child: Text('لا يوجد بيانات لعرضها.'));
                    },
                  ),
                  HeightSpace(16.h),
                  BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                      print("state: $state");
                      if (state is CategoryLoading) {
                        return CustomDropdown(
                          hint: "اختر الملعب",
                          items: [], // تأكد من أن `zone.name` هو النص المناسب
                          onChanged: (value) {
                            // قم بإجراء العمليات المطلوبة بعد تغيير القيمة
                            // على سبيل المثال، إرسال القيمة إلى الـ Cubit أو غيرها
                            print("الملعب المختار: $value");
                          },
                        );
                      } else if (state is CategoryFailure) {
                        print("error: ${state.message}");
                        return Center(child: Text('خطأ: ${state.message}'));
                      } else if (state is CategorySuccess) {
                        final category = state.categories;

                        return CustomDropdown(
                          hint: "اختر الملعب",
                          items: category.map((zone) => zone.name).toList(),
                          onChanged: (value) {
                            print("الملعب المختار: $value");
                          },
                        );
                      }
                      return Center(child: Text('لا يوجد بيانات لعرضها.'));
                    },
                  ),
                  CustomDropdown(
                      //  label: "اختر الماركة",
                      hint: "اختر الرياضة",
                      items: ["ملعب 1", "ملعب 2", "ملعب 3", "ملعب 4"],
                      onChanged: (value) {
                        // cubit.changeSelectedBrand(value!);
                        // cubit.getBrandTypes();
                      }),
                  HeightSpace(16.h),
                  Text(
                    "تاريخ الحجز",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  HeightSpace(16.h),
                  SizedBox(height: 400.h, child: CustomCalder()),
                  HeightSpace(16.h),
                  Text(
                    "وقت الحجز",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  HeightSpace(16.h),
                  Wrap(
                    children: List.generate(
                      5,
                      (index) => Container(
                        // height: 50.h,
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 4.h),
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary,
                          ),
                        ),
                        child: Text(
                          "7:00 PM",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.font16Bold.copyWith(
                            color: Color(0xff204523),
                          ),
                        ),
                      ),
                    ),
                  ),
                  HeightSpace(16.h),
                  Text(
                    "وقت الحجز",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  HeightSpace(16.h),
                  Wrap(
                    children: List.generate(
                      5,
                      (index) => Container(
                        // height: 50.h,
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 4.h),
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primary,
                          ),
                        ),
                        child: Text(
                          "60 دقيقة",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.font16Bold.copyWith(
                            color: Color(0xff204523),
                          ),
                        ),
                      ),
                    ),
                  ),
                  HeightSpace(50.h),
                ],
              ),
            ),
            CustomBookingButton(
              text: "اذهب للدفع",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
