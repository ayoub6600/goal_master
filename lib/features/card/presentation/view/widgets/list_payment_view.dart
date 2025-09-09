import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/bottom_sheet/base_bottom_sheet.dart';
import 'package:goal_master/core/components/button_app_two.dart';
import 'package:goal_master/core/components/page_wrapper.dart';

import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/balance/presentation/transaction_cubit/transaction_cubit.dart';
import 'package:goal_master/features/card/presentation/manager/cubit/card_cubit.dart';
import 'package:goal_master/features/card/presentation/view/widgets/top_up_sheet.dart';
import 'package:goal_master/features/card/presentation/view/widgets/top_up_sheet_visa.dart';

class ListPaymentView extends StatelessWidget {
  const ListPaymentView({super.key});
  Future<void> _handleTopUpResult(
      BuildContext context, bool? shouldReload) async {
    if (shouldReload == true) {
      final txCubit = context.read<TransactionCubit>();
      final balanceCubit = context.read<BalanceCubit>();

      txCubit.refresh();
      balanceCubit.getBalance();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true); // هيرجع للقائمة السابقة ومعاه true
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        allowBack: true,
        title: 'خدمات المحفظة',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              HeightSpace(16.w),
              ButtonAppTwo(
                assetIcon: Assets.creditCards,
                text: 'البطاقة المصرفية (اونلاين)',
                onTap: () async {
                  final cardCubit = context.read<CardCubit>();

                  final shouldReload = await baseBottomSheet(
                    context: context,
                    title: "شحن الرصيد",
                    hideNavBar: false,
                    showDragHandle: false,
                    child: BlocProvider.value(
                      value: cardCubit,
                      child: const TopUpSheetVisa(),
                    ),
                  );

                  await _handleTopUpResult(context, shouldReload);
                },
              ),
              HeightSpace(16.h),
              ButtonAppTwo(
                text: "شحن بالكرت",
                assetIcon: Assets.scratch,
                onTap: () async {
                  final cardCubit = context.read<CardCubit>();

                  final shouldReload = await baseBottomSheet(
                    context: context,
                    title: "شحن الرصيد",
                    hideNavBar: false,
                    showDragHandle: false,
                    child: BlocProvider.value(
                      value: cardCubit,
                      child: const TopUpSheet(),
                    ),
                  );

                  if (shouldReload == true) {
                    await _handleTopUpResult(context, shouldReload);
                  }
                },
              ),
            ],
          ),
        ));
  }
}
