import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/promotional_credit/presentation/venue_campaign_cubit.dart';
import 'package:goal_master/features/promotional_credit/presentation/promotional_credit_cubit.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';

class VenueCampaignCheckoutCard extends StatelessWidget {
  const VenueCampaignCheckoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueCampaignCubit, VenueCampaignState>(
      builder: (context, state) {
        final offer = state.selectedOffer;
        if (state.baseAmount <= 0) return const SizedBox.shrink();
        final discount = offer?.discount ?? 0;
        final total =
            (state.baseAmount - discount).clamp(0, double.infinity).toDouble();
        final percent = offer == null || state.baseAmount <= 0
            ? 0
            : (discount / state.baseAmount * 100).round();
        final coinsDiscount = context.select<CoinsCubit, double>(
          (cubit) => cubit.state.checkoutDiscount,
        );
        return BlocBuilder<PromotionalCreditCubit, PromotionalCreditState>(
          builder: (context, rewards) {
            final rewardAmount =
                rewards.useAtCheckout ? rewards.amountToUse : 0.0;
            final payable = (total - rewardAmount - coinsDiscount)
                .clamp(0, double.infinity)
                .toDouble();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xfff5f8f5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffe4ebe4)),
              ),
              child: Column(
                children: [
                  if (offer != null)
                    Row(children: [
                      const Icon(Icons.local_offer_outlined,
                          color: Color(0xff28743a), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(offer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Text('$percent% خصم',
                          style: const TextStyle(
                              color: Color(0xff168b36),
                              fontWeight: FontWeight.w800)),
                    ]),
                  const Divider(height: 18),
                  _PriceLine(
                    label: 'السعر الأساسي',
                    value: state.baseAmount,
                    muted: true,
                    struckThrough: offer != null,
                  ),
                  if (offer != null) ...[
                    const SizedBox(height: 6),
                    _PriceLine(
                      label: 'خصم العرض ($percent%)',
                      value: -discount,
                      color: const Color(0xff168b36),
                    ),
                  ],
                  const Divider(height: 18),
                  _PriceLine(
                      label: 'الإجمالي قبل المكافآت',
                      value: total,
                      emphasis: true),
                  if (coinsDiscount > 0) ...[
                    const SizedBox(height: 6),
                    _PriceLine(
                      label: 'خصم GM Coins',
                      value: -coinsDiscount,
                      color: const Color(0xff168b36),
                    ),
                  ],
                  if (rewardAmount > 0) ...[
                    const SizedBox(height: 6),
                    _PriceLine(
                      label: 'رصيد المكافآت',
                      value: -rewardAmount,
                      color: const Color(0xff168b36),
                    ),
                  ],
                  if (rewardAmount > 0 || coinsDiscount > 0) ...[
                    const Divider(height: 18),
                    _PriceLine(
                        label: 'المبلغ المستحق',
                        value: payable,
                        emphasis: true),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.color,
    this.muted = false,
    this.struckThrough = false,
    this.emphasis = false,
  });

  final String label;
  final double value;
  final Color? color;
  final bool muted;
  final bool struckThrough;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: color ?? (muted ? Colors.black54 : Colors.black87),
      fontSize: emphasis ? 15 : 13,
      fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
      decoration: struckThrough ? TextDecoration.lineThrough : null,
    );
    return Row(children: [
      Expanded(child: Text(label, style: style)),
      Text('${value < 0 ? '−' : ''}${value.abs().toStringAsFixed(2)} د.ل',
          style: style),
    ]);
  }
}
