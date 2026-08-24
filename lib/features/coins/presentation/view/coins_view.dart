import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/coins/data/model/coin_model.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/coin_burst_popup.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/redeem_coins_sheet.dart';

/// Gold/amber palette — deliberately distinct from the app's green
/// AppColors.primary so a coin genuinely reads as "a coin" at a glance.
class _CoinColors {
  static const gold = Color(0xFFFFB300);
  static const goldDark = Color(0xFFE59400);
  static const bg = Color(0xFFFFF8E1);
}

class CoinsView extends StatefulWidget {
  const CoinsView({super.key});

  @override
  State<CoinsView> createState() => _CoinsViewState();
}

class _CoinsViewState extends State<CoinsView> {
  final ScrollController _scrollController = ScrollController();
  bool _popupShown = false;

  @override
  void initState() {
    super.initState();
    context.read<CoinsCubit>().getBalance();
    context.read<CoinsCubit>().loadHistory(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final cubit = context.read<CoinsCubit>();
      if (!cubit.state.loadingHistory && cubit.state.hasMoreHistory) {
        cubit.loadHistory();
      }
    }
  }

  Future<void> _openRedeemSheet(CoinBalance balance) async {
    final redeemed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RedeemCoinsSheet(balance: balance),
    );
    if (redeemed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحويل الكوينز إلى محفظتك بنجاح 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _CoinColors.bg,
      appBar: AppBar(
        backgroundColor: _CoinColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('الكوينز', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<CoinsCubit, CoinsState>(
        listenWhen: (previous, current) =>
            current.justEarnedCoins != null && !_popupShown,
        listener: (context, state) {
          if (state.justEarnedCoins != null) {
            _popupShown = true;
            showCoinBurstPopup(context, state.justEarnedCoins!);
            context.read<CoinsCubit>().clearJustEarned();
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              final cubit = context.read<CoinsCubit>();
              await cubit.getBalance();
              await cubit.loadHistory(refresh: true);
            },
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalanceCard(state),
                const SizedBox(height: 20),
                Text('سجل الكوينز', style: AppTextStyles.font16Bold),
                const SizedBox(height: 8),
                if (state.history.isEmpty && !state.loadingHistory)
                  _buildEmptyHistory()
                else
                  ...state.history.map(_buildHistoryTile),
                if (state.loadingHistory)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(color: _CoinColors.gold)),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(CoinsState state) {
    final balance = state.balance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_CoinColors.gold, _CoinColors.goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _CoinColors.gold.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('رصيدك من الكوينز', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 34)),
              const SizedBox(width: 8),
              Text(
                state.loadingBalance && balance == null
                    ? '...'
                    : '${balance?.coinsBalance ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (balance != null) ...[
            const SizedBox(height: 4),
            Text(
              'يعادل تقريبًا ${balance.moneyValue} دينار',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            if (balance.pendingCoins > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${balance.pendingCoins} كوينز في الانتظار — تتفعّل بعد اكتمال حجزك',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (balance == null || !balance.isActive)
                  ? null
                  : () => _openRedeemSheet(balance),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _CoinColors.goldDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('تحويل إلى المحفظة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'اكسب كوينز من كل حجز تكمّله!',
            style: AppTextStyles.font14Medium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(CoinTransaction tx) {
    final isCredit = tx.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isCredit ? _CoinColors.gold : Colors.grey).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.add_circle : Icons.account_balance_wallet,
              color: isCredit ? _CoinColors.goldDark : Colors.grey.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? (isCredit ? 'مكافأة حجز' : 'تحويل إلى المحفظة'),
                  style: AppTextStyles.font14SemiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (tx.createdAt != null)
                      Text(
                        _formatDate(tx.createdAt!),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    if (tx.isPending) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _CoinColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'في الانتظار',
                          style: TextStyle(color: _CoinColors.goldDark, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${tx.amount}',
            style: TextStyle(
              color: isCredit ? _CoinColors.goldDark : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
