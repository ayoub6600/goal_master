import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/promotional_credit/presentation/promotional_credit_cubit.dart';

/// Amounts offered as one-tap top-ups, in LYD.
const List<int> kQuickTopUpAmounts = [20, 30, 50, 100];

/// The wallet's own greens: the brand colour and a deeper shade for depth.
const Color _walletDark = Color(0xFF2B6531);
const Color _walletTint = Color(0xFFEAF5EA);

String _money(num value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
}

/// The balance, the rewards credit and the three things you do with a wallet.
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.onTopUp,
    required this.onTransfer,
    required this.onCards,
  });

  final VoidCallback onTopUp;
  final VoidCallback onTransfer;
  final VoidCallback onCards;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, _walletDark],
        ),
        boxShadow: [
          BoxShadow(
            color: _walletDark.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A soft football-pitch circle in the corner, purely decorative.
          Positioned(
            left: -40.w,
            top: -50.h,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 14,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'رصيدك المتاح',
                    style: AppTextStyles.font14Bold.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              BlocBuilder<BalanceCubit, BalanceState>(
                builder: (context, state) {
                  if (state is BalanceLoaded) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _money(state.balance),
                          style: AppTextStyles.font24Bold.copyWith(
                            color: Colors.white,
                            fontSize: 36.sp,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.h),
                          child: Text(
                            'د.ل',
                            style: AppTextStyles.font16Bold.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  if (state is BalanceError) {
                    return Text(
                      'تعذر تحميل الرصيد — اسحب للتحديث',
                      style: AppTextStyles.font14Bold
                          .copyWith(color: Colors.white),
                    );
                  }
                  return SizedBox(
                    height: 40.h,
                    child: const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _WalletAction(
                      icon: Icons.add_rounded,
                      label: 'شحن',
                      onTap: onTopUp,
                      primary: true,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _WalletAction(
                      icon: Icons.send_rounded,
                      label: 'تحويل',
                      onTap: onTransfer,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _WalletAction(
                      icon: Icons.credit_card_rounded,
                      label: 'بطاقاتي',
                      onTap: onCards,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? _walletDark : Colors.white;
    return Material(
      color: primary ? Colors.white : Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 24),
              SizedBox(height: 4.h),
              Text(label, style: AppTextStyles.font14Bold.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The quick amounts as a row of equal chips. [selected] highlights one.
class QuickAmountChips extends StatelessWidget {
  const QuickAmountChips({super.key, required this.onSelected, this.selected});

  final ValueChanged<int> onSelected;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < kQuickTopUpAmounts.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: _AmountChip(
              amount: kQuickTopUpAmounts[i],
              selected: selected == kQuickTopUpAmounts[i],
              onTap: () => onSelected(kQuickTopUpAmounts[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : _walletTint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFCFE3CF),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$amount',
                style: AppTextStyles.font18Bold.copyWith(
                  color: selected ? Colors.white : _walletDark,
                  height: 1.1,
                ),
              ),
              Text(
                'د.ل',
                style: AppTextStyles.font12Regular.copyWith(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColors.fontColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section heading inside the wallet page.
class WalletSectionTitle extends StatelessWidget {
  const WalletSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.font16Bold),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// «مكافآت»: credit earned in games and offers. Spent on bookings only, so
/// it sits under the wallet balance rather than inside it, with the rule one
/// tap away on the «؟».
class WalletRewardsCard extends StatelessWidget {
  const WalletRewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionalCreditCubit, PromotionalCreditState>(
      builder: (context, state) {
        final amount = state.balance;
        if (amount == null || amount <= 0) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _explainRewards(context, amount),
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF2DDA4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCE9B8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard_rounded,
                        color: Color(0xFFB7791F), size: 20),
                  ),
                  SizedBox(width: 10.w),
                  Text('مكافآت',
                      style: AppTextStyles.font16Bold
                          .copyWith(color: const Color(0xFF7A5414))),
                  Padding(
                    padding: EdgeInsets.all(6.w),
                    child: const Icon(Icons.help_outline_rounded,
                        size: 18, color: Color(0xFFB7791F)),
                  ),
                  const Spacer(),
                  Text(
                    '${_money(amount)} د.ل',
                    style: AppTextStyles.font18Bold
                        .copyWith(color: const Color(0xFF7A5414)),
                  ),
                  SizedBox(width: 6.w),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _explainRewards(BuildContext context, num amount) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE9B8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard_rounded,
                    color: Color(0xFFB7791F), size: 30),
              ),
              SizedBox(height: 12.h),
              Text('مكافآتك: ${_money(amount)} د.ل',
                  style: AppTextStyles.font18Bold),
              SizedBox(height: 14.h),
              for (final line in const [
                (
                  Icons.sports_soccer_rounded,
                  'للحجز فقط: تُخصم تلقائيًا عند دفع حجز.'
                ),
                (Icons.block_rounded, 'ما تتحولش لشخص آخر وما تنسحبش كفلوس.'),
                (Icons.emoji_events_outlined, 'تكسبها من الألعاب وهدية التسجيل وتكرار الحجز.'),
              ])
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    children: [
                      Icon(line.$1, size: 20, color: AppColors.primary),
                      SizedBox(width: 10.w),
                      Expanded(
                        child:
                            Text(line.$2, style: AppTextStyles.font14Regular),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تمام'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
