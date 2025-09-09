import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/bottom_sheet/base_bottom_sheet.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/balance/presentation/send_money_cubit/send_money_cubit.dart'
    show SendMoneyCubit;
import 'package:goal_master/features/balance/presentation/transaction_cubit/transaction_cubit.dart';
import 'package:goal_master/features/card/presentation/manager/cubit/card_cubit.dart';
import 'package:goal_master/features/card/presentation/view/send_money_view.dart';

import 'package:goal_master/features/card/presentation/view/transaction_item.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CardView extends StatelessWidget {
  const CardView({super.key});

  @override
  Widget build(BuildContext context) {
    final txCubit = context.read<TransactionCubit>();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: PageWrapper(
        title: "المحفظة",
        child: RefreshIndicator(
          onRefresh: () async => txCubit.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeightSpace(10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            BlocBuilder<BalanceCubit, BalanceState>(
                              builder: (context, state) {
                                if (state is BalanceLoading) {
                                  return Text(
                                    "...",
                                    style: AppTextStyles.font16SemiBold,
                                  );
                                } else if (state is BalanceLoaded) {
                                  return Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          "الرصيد الحالي",
                                          style:
                                              AppTextStyles.font16Bold.copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        Text(
                                          state.balance.toString(),
                                          style:
                                              AppTextStyles.font24Bold.copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        HeightSpace(8.h),
                                      ],
                                    ),
                                  );
                                } else if (state is BalanceError) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.w,
                                      child: Text(
                                        " ${state.errMessage}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(color: AppColors.black),
                                      ),
                                    ),
                                  );
                                }
                                return Center(child: Text("No Data"));
                              },
                            ),
                            HeightSpace(8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ButtonApp(
                                    assetIconPath: Assets.imagesPngImageWallet2,
                                    text: "شحن",
                                    backGround: AppColors.white,
                                    textColor: AppColors.obsidianBlack,
                                    onTap: () async {
                                      final txCubit =
                                          context.read<TransactionCubit>();
                                      final balanceCubit =
                                          context.read<BalanceCubit>();

                                      final shouldReload = await push(
                                          RoutesKeys.kListPaymentView, context);

                                      if (shouldReload == true) {
                                        txCubit.refresh();
                                        balanceCubit.getBalance();
                                      }
                                    },
                                  ),
                                ),
                                WidthSpace(8.w),
                                Expanded(
                                  child: ButtonApp(
                                    //  icon: Icons.transfer_within_a_station,
                                    assetIconPath: Assets.sendMo,
                                    text: "تحويل فلوس",
                                    backGround: AppColors.white,
                                    textColor: AppColors.obsidianBlack,
                                    onTap: () async {
                                      final cardCubit =
                                          context.read<CardCubit>();
                                      final sendCubit =
                                          context.read<SendMoneyCubit>();
                                      final txCubit =
                                          context.read<TransactionCubit>();
                                      final balanceCubit =
                                          context.read<BalanceCubit>();

                                      final shouldReload =
                                          await baseBottomSheet(
                                        context: context,
                                        title: "تحويل فلوس",
                                        hideNavBar: false,
                                        showDragHandle: false,
                                        child: MultiBlocProvider(
                                          providers: [
                                            BlocProvider.value(
                                                value: cardCubit),
                                            BlocProvider.value(
                                                value: sendCubit),
                                          ],
                                          child: const SendMoneyView(),
                                        ),
                                      );

                                      if (shouldReload == true) {
                                        txCubit.refresh();
                                        balanceCubit.getBalance();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionSuccess) {
                    final pagingController = state.pagingController;

                    return PagedSliverList<int, Transaction>(
                      pagingController: pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Transaction>(
                        itemBuilder: (context, tx, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TransactionItem(transaction: tx),
                          );
                        },
                        firstPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        newPageProgressIndicatorBuilder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                        noItemsFoundIndicatorBuilder: (_) => const Center(
                          child: Text("لا توجد معاملات"),
                        ),
                        firstPageErrorIndicatorBuilder: (_) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "حدث خطأ أثناء تحميل المعاملات",
                                style: AppTextStyles.font16Bold.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () =>
                                    context.read<TransactionCubit>().refresh(),
                                child: const Text("إعادة المحاولة"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
