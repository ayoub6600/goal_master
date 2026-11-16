import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/card/presentation/view/widgets/wallet_widgets.dart';

/// Top-up by bank card: pick a quick amount or type one, then pay on the
/// Moamalat page. The server signs the checkout and confirms the payment.
class TopUpSheetVisa extends StatefulWidget {
  const TopUpSheetVisa({
    super.key,
    this.embedded = false,
    this.onCompleted,
    this.initialAmount,
  });

  final bool embedded;
  final VoidCallback? onCompleted;
  final int? initialAmount;

  @override
  State<TopUpSheetVisa> createState() => _TopUpSheetVisaState();
}

class _TopUpSheetVisaState extends State<TopUpSheetVisa> {
  late final TextEditingController amountController = TextEditingController(
    text: widget.initialAmount?.toString() ?? '',
  );
  bool _submitting = false;

  int get _amount => int.tryParse(amountController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final amount = _amount;
    if (amount <= 0) {
      showCustomFailureToast('اختر مبلغًا أو اكتبه');
      return;
    }

    setState(() => _submitting = true);
    final res = await context.push(
      RoutesKeys.kPaymentWebViewPage,
      extra: {'amount': amount.toString()},
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res == true) {
      showCustomSuccessToast('تم شحن $amount د.ل بنجاح');
      if (widget.embedded) {
        widget.onCompleted?.call();
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('اختر المبلغ', style: AppTextStyles.font16Bold),
          SizedBox(height: 10.h),
          QuickAmountChips(
            selected: kQuickTopUpAmounts.contains(amount) ? amount : null,
            onSelected: (v) => amountController.text = '$v',
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            textAlign: TextAlign.center,
            style: AppTextStyles.font18Bold,
            decoration: InputDecoration(
              hintText: 'أو اكتب مبلغًا آخر',
              hintStyle: AppTextStyles.font14Regular
                  .copyWith(color: AppColors.fontColor),
              suffixText: 'د.ل',
              filled: true,
              fillColor: const Color(0xFFF7F9F7),
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE1E8E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE1E8E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ButtonApp(
            text: _submitting
                ? 'جارٍ فتح صفحة الدفع...'
                : amount > 0
                    ? 'ادفع $amount د.ل'
                    : 'متابعة للدفع',
            backGround: AppColors.primary,
            textColor: Colors.white,
            isLoading: _submitting,
            enabled: amount > 0,
            onTap: _pay,
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 14, color: AppColors.fontColor),
              SizedBox(width: 4.w),
              Text(
                'دفع آمن عبر معاملات — يُضاف الرصيد بعد تأكيد البنك',
                style: AppTextStyles.font12Regular
                    .copyWith(color: AppColors.fontColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
