import 'package:flutter/material.dart';
import 'package:goal_master/features/card/presentation/manager/card_cubit/card_cubit.dart';
import 'package:goal_master/features/card/presentation/view/widgets/wallet_widgets.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/saved_cards/presentation/saved_cards_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
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

  /// The top-up sheet. CardCubit lives on this page's route, not above the
  /// sheet's own route — it has to be handed over, or the prepaid-card form
  /// can't find it (a grey box in release builds).
  void _openTopUp({int? amount}) {
    final cardCubit = context.read<CardCubit>();
    _showWalletSheet(
      title: 'شحن المحفظة',
      child: BlocProvider<CardCubit>.value(
        value: cardCubit,
        child: ListPaymentView(
          embedded: true,
          initialAmount: amount,
          onUpdated: _refreshWallet,
        ),
      ),
    );
  }

  /// «بطاقاتي»: the saved cards in their own sheet.
  void _openSavedCards() {
    final userId = SharedPreferenceUtil.getInt(PrefKey.userId);
    _showWalletSheet(
      title: 'بطاقاتي المحفوظة',
      child: SavedCardsPage(
        ownerId: userId > 0 ? 'customer:$userId' : '',
        embedded: true,
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
                      HeightSpace(4.h),
                      WalletBalanceCard(
                        onTopUp: () => _openTopUp(),
                        onTransfer: _openTransfer,
                        onCards: _openSavedCards,
                      ),
                      const WalletRewardsCard(),
                      HeightSpace(20.h),
                      const WalletSectionTitle('آخر المعاملات'),
                      HeightSpace(4.h),
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
