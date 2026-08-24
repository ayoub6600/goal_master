import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/coins/data/model/coin_model.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';

const _gold = Color(0xFFFFB300);
const _goldDark = Color(0xFFE59400);

class RedeemCoinsSheet extends StatefulWidget {
  const RedeemCoinsSheet({super.key, required this.balance});

  final CoinBalance balance;

  @override
  State<RedeemCoinsSheet> createState() => _RedeemCoinsSheetState();
}

class _RedeemCoinsSheetState extends State<RedeemCoinsSheet> {
  late final TextEditingController _controller;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _coins = widget.balance.coinsBalance;
    _controller = TextEditingController(text: _coins.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _moneyPreview =>
      widget.balance.redeemRate > 0 ? (_coins / widget.balance.redeemRate) : 0;

  Future<void> _confirm() async {
    final cubit = context.read<CoinsCubit>();
    final ok = await cubit.redeem(_coins);
    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: BlocBuilder<CoinsCubit, CoinsState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text('تحويل الكوينز إلى المحفظة', style: AppTextStyles.font18Bold),
                const SizedBox(height: 4),
                Text(
                  'رصيدك الحالي: ${widget.balance.coinsBalance} كوينز',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _goldDark),
                  decoration: InputDecoration(
                    suffixText: 'كوينز',
                    filled: true,
                    fillColor: const Color(0xFFFFF8E1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _coins = int.tryParse(value) ?? 0);
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'سيُضاف ${_moneyPreview.toStringAsFixed(2)} دينار إلى محفظتك',
                      style: const TextStyle(color: _goldDark, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'الحد الأدنى للتحويل: ${widget.balance.minRedeemCoins} كوينز',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                if (state.redeemError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.redeemError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.redeeming ||
                            _coins < widget.balance.minRedeemCoins ||
                            _coins > widget.balance.coinsBalance
                        ? null
                        : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: state.redeeming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('تأكيد التحويل', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
