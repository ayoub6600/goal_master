import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

const _gold = Color(0xFFFFB300);
const _goldDark = Color(0xFFE59400);

/// Celebratory "you earned N coins" overlay — auto-dismisses on its own
/// after a couple seconds, or the customer can tap anywhere to skip it if
/// they're in a hurry. Self-contained (no cubit dependency) so it can be
/// triggered from anywhere a coins balance increase is detected.
Future<void> showCoinBurstPopup(BuildContext context, int coins) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'coins_earned',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, _, __) => _CoinBurstContent(coins: coins),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.7 + (curved.value * 0.3), child: child),
      );
    },
  );
}

class _CoinBurstContent extends StatefulWidget {
  const _CoinBurstContent({required this.coins});

  final int coins;

  @override
  State<_CoinBurstContent> createState() => _CoinBurstContentState();
}

class _CoinBurstContentState extends State<_CoinBurstContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _autoDismiss = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gold, _goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.003)
                        ..rotateY(_spinController.value * 2 * pi),
                      child: child,
                    );
                  },
                  child: const Text('🪙', style: TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'مبروك! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'كسبت ${widget.coins} كوينز',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
