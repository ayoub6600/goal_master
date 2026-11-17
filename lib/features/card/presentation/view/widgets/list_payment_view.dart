import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/card/presentation/view/widgets/top_up_sheet.dart';
import 'package:goal_master/features/card/presentation/view/widgets/top_up_sheet_visa.dart';
import 'package:goal_master/features/lypay/lypay_topup_view.dart';

/// Topping up the wallet: by bank card (online, with quick amounts) or with a
/// prepaid scratch card. One screen, two tabs — it used to be a list of two
/// buttons that each opened a bare form.
class ListPaymentView extends StatefulWidget {
  const ListPaymentView({
    super.key,
    this.embedded = false,
    this.onUpdated,
    this.initialAmount,
  });

  final bool embedded;
  final VoidCallback? onUpdated;

  /// Pre-selects a quick amount on the bank-card tab.
  final int? initialAmount;

  @override
  State<ListPaymentView> createState() => _ListPaymentViewState();
}

class _ListPaymentViewState extends State<ListPaymentView> {
  int _tab = 0; // 0 bank card, 1 LYPay transfer, 2 prepaid card

  void _completed() {
    widget.onUpdated?.call();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _MethodSwitch(
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          SizedBox(height: 16.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (_tab) {
              0 => TopUpSheetVisa(
                  key: const ValueKey('bank'),
                  embedded: true,
                  initialAmount: widget.initialAmount,
                  onCompleted: _completed,
                ),
              1 => LypayTopUpView(
                  key: const ValueKey('lypay'),
                  onApproved: widget.onUpdated,
                ),
              _ => TopUpSheet(
                  key: const ValueKey('prepaid'),
                  embedded: true,
                  onCompleted: _completed,
                ),
            },
          ),
        ],
      ),
    );

    if (widget.embedded) return content;
    return PageWrapper(
      allowBack: true,
      title: 'شحن المحفظة',
      child: SingleChildScrollView(child: content),
    );
  }
}

class _MethodSwitch extends StatelessWidget {
  const _MethodSwitch({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(int index, IconData icon, String label) {
      final active = selected == index;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 11.h),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: active ? AppColors.primary : AppColors.fontColor),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: AppTextStyles.font14Bold.copyWith(
                    color: active ? AppColors.primary : AppColors.fontColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          tab(0, Icons.credit_card_rounded, 'بطاقة'),
          tab(1, Icons.account_balance_rounded, 'LYPay'),
          tab(2, Icons.confirmation_number_outlined, 'كرت شحن'),
        ],
      ),
    );
  }
}
