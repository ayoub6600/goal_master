import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/promotional_credit/presentation/promotional_credit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/monthly_booking_cubit/monthly_booking_cubit.dart';

class PromotionalCreditCheckoutCard extends StatelessWidget {
  const PromotionalCreditCheckoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionalCreditCubit, PromotionalCreditState>(
      builder: (context, state) {
        final quote = state.quote;
        if (quote == null || !quote.canRedeem) return const SizedBox.shrink();
        final unavailableReason = context.select<AddBookingCubit, String?>(
          (cubit) => cubit.selectedPaymentType == 4
              ? null
              : 'رصيد المكافآت متاح مع الدفع من المحفظة فقط.',
        );
        final isMonthly = context.select<MonthlyBookingCubit, bool>(
          (cubit) => cubit.state.isMonthly,
        );
        final disabled = unavailableReason != null || isMonthly;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F7EF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB8D8B1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Color(0xFF43894B)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('رصيد المكافآت'),
                    Text('متاح ${quote.balance.toStringAsFixed(2)} د.ل'),
                    if (disabled)
                      Text(
                        isMonthly
                            ? 'رصيد المكافآت غير متاح للحجز الشهري.'
                            : unavailableReason!,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      )
                    else if (state.useAtCheckout)
                      Text(
                          'سيُستخدم ${state.amountToUse.toStringAsFixed(2)} د.ل'),
                  ],
                ),
              ),
              Switch(
                value: disabled ? false : state.useAtCheckout,
                activeThumbColor: const Color(0xFF43894B),
                onChanged: disabled
                    ? null
                    : (value) => context
                        .read<PromotionalCreditCubit>()
                        .setUseAtCheckout(value),
              ),
            ],
          ),
        );
      },
    );
  }
}
