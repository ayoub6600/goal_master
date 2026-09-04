import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';

const _gold = Color(0xFFFFB300);
const _goldDark = Color(0xFFE59400);
const _goldBg = Color(0xFFFFF8E1);

/// Checkout control for spending GM Coins on the booking being confirmed.
///
/// Renders nothing at all when there is nothing to offer (module disabled,
/// balance under the minimum, quote failed) — the customer should never see a
/// dead or greyed-out coins box.
///
/// Every number shown comes from the server quote; nothing here is computed
/// locally, and the amount displayed is only ever a preview — the backend
/// re-validates and re-prices on submit.
class CoinsCheckoutCard extends StatelessWidget {
  const CoinsCheckoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinsCubit, CoinsState>(
      buildWhen: (previous, current) =>
          previous.checkoutQuote != current.checkoutQuote ||
          previous.useCoinsAtCheckout != current.useCoinsAtCheckout ||
          previous.selectedCheckoutCoins != current.selectedCheckoutCoins,
      builder: (context, state) {
        final quote = state.checkoutQuote;
        if (quote == null || !quote.canRedeem) {
          return const SizedBox.shrink();
        }

        final enabled = state.useCoinsAtCheckout;
        final coins = state.coinsToRedeem;
        final discount = state.checkoutDiscount;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _goldBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('استخدم GM Coins', style: AppTextStyles.font14Bold),
                        const SizedBox(height: 2),
                        Text(
                          'رصيدك: ${quote.coinsBalance} كوينز',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    activeThumbColor: _goldDark,
                    onChanged: (value) =>
                        context.read<CoinsCubit>().setUseCoinsAtCheckout(value),
                  ),
                ],
              ),
              if (enabled) ...[
                const Divider(height: 20),
                if (quote.maxRedeemableCoins > quote.minRedeemCoins)
                  Slider(
                    value: state.selectedCheckoutCoins
                        .clamp(quote.minRedeemCoins, quote.maxRedeemableCoins)
                        .toDouble(),
                    min: quote.minRedeemCoins.toDouble(),
                    max: quote.maxRedeemableCoins.toDouble(),
                    activeColor: _goldDark,
                    inactiveColor: _gold.withValues(alpha: 0.3),
                    label: '$coins',
                    divisions: _divisionsFor(quote.minRedeemCoins, quote.maxRedeemableCoins),
                    onChanged: (value) =>
                        context.read<CoinsCubit>().setCheckoutCoins(value.round()),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تستخدم $coins كوينز',
                      style: AppTextStyles.font14Medium,
                    ),
                    Text(
                      'توفر ${discount.toStringAsFixed(2)} د.ل',
                      style: AppTextStyles.font14Bold
                          .copyWith(color: _goldDark),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'أقصى خصم متاح لهذا الحجز: ${quote.maxDiscountValue.toStringAsFixed(2)} د.ل',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Slider divisions in whole coins, capped so a huge balance doesn't produce
  /// thousands of stops (Flutter renders a tick per division).
  int _divisionsFor(int min, int max) {
    final span = max - min;
    if (span <= 0) return 1;
    return span > 100 ? 100 : span;
  }
}
