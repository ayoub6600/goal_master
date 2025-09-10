import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/features/card/presentation/manager/checkout_cubit/payment_cubit/payment_state.dart';

class TopUpSheetVisa extends StatefulWidget {
  const TopUpSheetVisa({super.key});

  @override
  State<TopUpSheetVisa> createState() => _TopUpSheetVisaState();
}

class _TopUpSheetVisaState extends State<TopUpSheetVisa> {
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ادخل المبلغ",
            style: AppTextStyles.font16Bold.copyWith(color: Colors.black),
          ),
          HeightSpace(8.h),
          CustomTextField(
            hint: "ادخل المبلغ",
            controller: amountController,
            inputType: TextInputType.number,
          ),
          HeightSpace(16.h),
          ButtonApp(
            text: "تأكيد الشحن",
            backGround: AppColors.primary,
            textColor: Colors.white,
            onTap: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("من فضلك أدخل مبلغ صحيح")),
                );
                return;
              }

              final amountInMilli = (amount).round();

              Navigator.pop(context);

              final res = await context.push(
                RoutesKeys.kPaymentWebViewPage,
                extra: {
                  'amount': amountInMilli.toString(),
                },
              );
              if (res is PaymentResult &&
                  res.status == PaymentResultStatus.completed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم الشحن بنجاح")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
