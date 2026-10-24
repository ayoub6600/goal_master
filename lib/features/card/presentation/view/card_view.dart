import 'package:flutter/material.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/saved_cards/presentation/saved_cards_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/balance/presentation/send_money_cubit/send_money_cubit.dart'
    show SendMoneyCubit, SendMoneyState, SendMoneyStatus;
import 'package:goal_master/features/balance/presentation/transaction_cubit/transaction_cubit.dart';
import 'package:goal_master/features/card/presentation/view/send_money_view.dart';
import 'package:goal_master/features/card/presentation/view/widgets/list_payment_view.dart';

import 'package:goal_master/features/card/presentation/view/transaction_item.dart';
import 'package:goal_master/features/promotional_credit/presentation/promotional_credit_cubit.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CardView extends StatefulWidget {
  const CardView({super.key});

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  bool _showSavedCards = false;
  bool _promoBalanceRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_promoBalanceRequested) {
      _promoBalanceRequested = true;
      context.read<PromotionalCreditCubit>().loadBalance();
    }
  }

  void _refreshWallet() {
    context.read<TransactionCubit>().refresh();
    context.read<BalanceCubit>().getBalance();
  }

  Future<void> _showWalletSheet({
    required String title,
    required Widget child,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  title: Text(title, textAlign: TextAlign.right),
                  trailing: IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTopUp() {
    _showWalletSheet(
      title: 'شحن المحفظة',
      child: ListPaymentView(
        embedded: true,
        onUpdated: _refreshWallet,
      ),
    );
  }

  void _openTransfer() {
    final sendMoneyCubit = context.read<SendMoneyCubit>();
    _showWalletSheet(
      title: 'تحويل فلوس',
      child: BlocProvider<SendMoneyCubit>.value(
        value: sendMoneyCubit,
        child: BlocListener<SendMoneyCubit, SendMoneyState>(
          listener: (context, state) {
            if (state.status == SendMoneyStatus.success) _refreshWallet();
          },
          child: const SendMoneyView(),
        ),
      ),
    );
  }

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
          onRefresh: () async {
            txCubit.refresh();
            //BalanceCubit
            context.read<BalanceCubit>().getBalance();
            context.read<PromotionalCreditCubit>().loadBalance();
          },
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
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.credit_card_outlined,
                                  color: Colors.green),
                              title: const Text('بطاقاتي المحفوظة'),
                              trailing: Icon(_showSavedCards
                                  ? Icons.expand_less
                                  : Icons.chevron_left),
                              onTap: () {
                                setState(
                                    () => _showSavedCards = !_showSavedCards);
                              },
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              child: _showSavedCards
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 12),
                                      child: Builder(builder: (context) {
                                        final userId =
                                            SharedPreferenceUtil.getInt(
                                                PrefKey.userId);
                                        return SavedCardsPage(
                                          ownerId: userId > 0
                                              ? 'customer:$userId'
                                              : '',
                                          embedded: true,
                                        );
                                      }),
                                    )
                                  : const SizedBox(width: double.infinity),
                            ),
                          ],
                        ),
                      ),
                      HeightSpace(12.h),
                      BlocBuilder<PromotionalCreditCubit,
                          PromotionalCreditState>(
                        builder: (context, state) {
                          final amount = state.balance;
                          if (amount == null || amount <= 0) {
                            return const SizedBox.shrink();
                          }
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F7EF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFB8D8B1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.card_giftcard,
                                    color: Color(0xFF43894B)),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'رصيد المكافآت للحجز فقط',
                                    style: AppTextStyles.font14Bold,
                                  ),
                                ),
                                Text(
                                  '${amount.toStringAsFixed(2)} د.ل',
                                  style: AppTextStyles.font16Bold.copyWith(
                                    color: const Color(0xFF43894B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
                                    onTap: _openTopUp,
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
                                    onTap: _openTransfer,
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
                      shrinkWrapFirstPageIndicators: true,
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
                        noItemsFoundIndicatorBuilder: (_) => Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 32),
                          child: Center(
                            child: Text("لا توجد معاملات"),
                          ),
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
