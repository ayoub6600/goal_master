import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/coupons/data/coupon_repo.dart';
import 'package:goal_master/features/coupons/presentation/checkout_coupon_cubit.dart';

const _ink = Color(0xFF0D2C46);
const _ticket = Color(0xFFF2FBF3);

/// «كود الخصم» on the checkout step: type a code, or tap one of your own
/// coupons (won in a game or given by the admin). The discount shown is the
/// server's preview; the booking request re-validates the code.
class CouponCheckoutCard extends StatefulWidget {
  const CouponCheckoutCard({super.key});

  @override
  State<CouponCheckoutCard> createState() => _CouponCheckoutCardState();
}

class _CouponCheckoutCardState extends State<CouponCheckoutCard> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _apply([String? code]) async {
    final value = code ?? _controller.text;
    if (code != null) _controller.text = code;
    _focus.unfocus();
    await context.read<CheckoutCouponCubit>().apply(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCouponCubit, CheckoutCouponState>(
      builder: (context, state) {
        final applied = state.applied;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: applied != null ? _ticket : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: applied != null
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.inactive4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                      child:
                          Text('كود الخصم', style: AppTextStyles.font14Bold)),
                  if (state.usableHere.isNotEmpty && applied == null)
                    Text(
                      'لديك ${state.usableHere.length} ${state.usableHere.length == 1 ? 'قسيمة' : 'قسائم'}',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (applied != null)
                _AppliedCoupon(
                    preview: applied,
                    onRemove: () {
                      _controller.clear();
                      context.read<CheckoutCouponCubit>().remove();
                    })
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        textDirection: TextDirection.ltr,
                        onSubmitted: (_) => _apply(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, letterSpacing: 1.2),
                        decoration: InputDecoration(
                          hintText: 'اكتب الكود هنا',
                          hintTextDirection: TextDirection.rtl,
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.inactive3,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: state.checking ? null : () => _apply(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state.checking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('تطبيق'),
                      ),
                    ),
                  ],
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: AppColors.errorRed),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(state.error!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                ],
                if (state.usableHere.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('قسائمك',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.usableHere.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final c = state.usableHere[i];
                        return _CouponChip(
                            coupon: c,
                            onTap:
                                state.checking ? null : () => _apply(c.code));
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AppliedCoupon extends StatelessWidget {
  const _AppliedCoupon({required this.preview, required this.onRemove});
  final CouponPreview preview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = preview.coupon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            const SizedBox(width: 6),
            Text(c.code,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _ink)),
            const Spacer(),
            Text('- ${preview.discount.toStringAsFixed(2)} د.ل',
                style: AppTextStyles.font14Bold
                    .copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          [
            'خصم ${c.headline}',
            if (!c.isFixed && c.maxDiscount > 0)
              'حتى ${c.maxDiscount.toStringAsFixed(0)} د.ل',
            if (c.branchName != null) 'في ${c.branchName}',
          ].join(' · '),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
                foregroundColor: AppColors.errorRed, padding: EdgeInsets.zero),
            child: const Text('إزالة الكود'),
          ),
        ),
      ],
    );
  }
}

class _CouponChip extends StatelessWidget {
  const _CouponChip({required this.coupon, this.onTap});
  final CustomerCoupon coupon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ticket,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (coupon.fromGame)
                    const Text('⚽ ', style: TextStyle(fontSize: 12)),
                  Text('خصم ${coupon.headline}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                coupon.expiresAt != null
                    ? 'حتى ${coupon.expiresAt}'
                    : coupon.code,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
