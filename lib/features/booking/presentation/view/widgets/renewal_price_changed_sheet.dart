import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

/// The price moved between the quote and the tap.
///
/// Nothing was charged. Shown rather than absorbed silently: taking a larger
/// amount than the customer agreed to would be taking money they never said
/// yes to, however small the difference.
///
/// Returns true if they accept the new price.
Future<bool?> showRenewalPriceChangedSheet(
  BuildContext context, {
  required double newTotal,
  required double newPricePerOccurrence,
  required double previousTotal,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          Text(
            "تغيّر السعر",
            style: AppTextStyles.font18Bold.copyWith(color: AppColors.darkBlue),
          ),
          HeightSpace(10.h),
          Text(
            "لم يتم خصم أي مبلغ. السعر تغيّر منذ آخر مراجعة:",
            style:
                AppTextStyles.font14Regular.copyWith(color: AppColors.mainGrey),
          ),
          HeightSpace(12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.lightWhite3,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "السعر السابق: ${previousTotal.toStringAsFixed(2)} د.ل",
                  style: AppTextStyles.font12Regular.copyWith(
                    color: AppColors.mainGrey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                HeightSpace(4.h),
                Text(
                  "السعر الجديد: ${newTotal.toStringAsFixed(2)} د.ل",
                  style: AppTextStyles.font16Bold
                      .copyWith(color: AppColors.darkBlue),
                ),
                Text(
                  "${newPricePerOccurrence.toStringAsFixed(2)} د.ل للموعد الواحد",
                  style: AppTextStyles.font12Regular
                      .copyWith(color: AppColors.mainGrey),
                ),
              ],
            ),
          ),
          HeightSpace(20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: Text(
                "موافق — تجديد بـ ${newTotal.toStringAsFixed(2)} د.ل",
                style: AppTextStyles.font14Bold.copyWith(color: Colors.white),
              ),
            ),
          ),
          HeightSpace(8.h),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(false),
              child: Text(
                "تراجع",
                style:
                    AppTextStyles.font14Bold.copyWith(color: AppColors.mainGrey),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
