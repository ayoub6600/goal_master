import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_calder.dart';
import 'package:goal_master/core/components/custom_drop_down.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/view/booking_items_details.dart.dart';

class BookingDetails extends StatelessWidget {
  const BookingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "تفاصيل الحجز",
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
                  CustomDropdown(
                      //  label: "اختر الماركة",
                      hint: "اختر الماركة",
                      items: ["ملعب 1", "ملعب 2", "ملعب 3", "ملعب 4"],
                      onChanged: (value) {
                        // cubit.changeSelectedBrand(value!);
                        // cubit.getBrandTypes();
                      }),
                  HeightSpace(16.h),
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
