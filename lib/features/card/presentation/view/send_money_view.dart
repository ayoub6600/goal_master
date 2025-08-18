// send_money_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/balance/presentation/send_money_cubit/send_money_cubit.dart';

class SendMoneyView extends StatelessWidget {
  const SendMoneyView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SendMoneyCubit>();

    return BlocConsumer<SendMoneyCubit, SendMoneyState>(
      listener: (context, state) async {
        if (state.status == SendMoneyStatus.success) {
          // Toast اختياري
          showCustomSuccessToast("تم التحويل بنجاح");

          final receiver = cubit.receiverIdController.text.trim();
          final amount = cubit.amountController.text.trim();

          // اظهر Dialog النجاح وانتظر إغلاقه
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة النجاح
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80.r,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // العنوان
                      Text(
                        "تم التحويل بنجاح",
                        style: AppTextStyles.font20Bold.copyWith(
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20.h),

                      // بطاقة رقم المستلم
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: AppColors.primary),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                "المستلم: $receiver",
                                style: AppTextStyles.font14Bold
                                    .copyWith(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // بطاقة المبلغ
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                "المبلغ: $amount د.ل",
                                style: AppTextStyles.font14Bold
                                    .copyWith(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // زر المتابعة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "متابعة",
                            style: AppTextStyles.font16Bold.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // بعد إغلاق الـ Dialog: نظّف وأقفل الـ BottomSheet مع نتيجة نجاح
          cubit.receiverIdController.clear();
          cubit.amountController.clear();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          }
        } else if (state.status == SendMoneyStatus.error &&
            state.errorMessage != null) {
          showCustomFailureToast(state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == SendMoneyStatus.loading;

        return AbsorbPointer(
          absorbing: isLoading,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 12.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // مناسب لـ BottomSheet
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رقم المستلم
                Text("رقم المستلم",
                    style:
                        AppTextStyles.font16Bold.copyWith(color: Colors.black)),
                HeightSpace(8.h),
                CustomTextField(
                  controller: cubit.receiverIdController,
                  hint: "أدخل رقم المستلم",
                  inputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                HeightSpace(16.h),

                // المبلغ
                Text("المبلغ",
                    style:
                        AppTextStyles.font16Bold.copyWith(color: Colors.black)),
                HeightSpace(8.h),
                CustomTextField(
                  hint: "0.00",
                  controller: cubit.amountController,
                  inputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),

                HeightSpace(16.h),

                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ButtonApp(
                        text: "تأكيد التحويل",
                        backGround: state.isFormValid
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        textColor: Colors.white,
                        onTap: state.isFormValid ? cubit.submit : null,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
