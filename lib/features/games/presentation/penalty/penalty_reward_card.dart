import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';

const _gold = Color(0xffffc928);
const _pitchGreen = Color(0xff1f6b34);

String _money(num v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// The end-of-shootout panel: scoreline, then whatever the server granted.
class PenaltyResultPanel extends StatelessWidget {
  const PenaltyResultPanel({
    super.key,
    required this.result,
    required this.goalsToWin,
    required this.kicksTaken,
    required this.onPlayAgain,
    required this.onExit,
    this.summary,
    this.lostNote,
  });

  /// Replaces the penalty-specific advice shown after a loss.
  final String? lostNote;

  /// Replaces the goals line, for other games sharing this panel.
  final String? summary;
  final PenaltyResult result;
  final int goalsToWin, kicksTaken;
  final VoidCallback onPlayAgain, onExit;

  @override
  Widget build(BuildContext context) {
    final won = result.won;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xf20c1712),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: won ? _gold.withValues(alpha: .55) : Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(won ? Icons.emoji_events_rounded : Icons.sports_soccer,
            size: 56, color: won ? _gold : Colors.white54),
        const SizedBox(height: 8),
        Text(won ? 'فزت بالتحدي!' : 'حظ أوفر المرة القادمة',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
            summary ??
                (won
                    ? 'سجّلت ${result.goalsScored} من $kicksTaken ركلات'
                    : 'سجّلت ${result.goalsScored} — كنت تحتاج $goalsToWin أهداف'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 18),
        _reward(),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              onPressed: onExit,
              child: const Text('العودة'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: const Color(0xff1b1300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              onPressed: onPlayAgain,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('العب مجددًا',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _reward() {
    final d = result.rewardDetails;
    if (result.hasPrize) {
      switch (result.rewardType) {
        case 'coupon':
        case 'premium_coupon':
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PenaltyCouponCard(
                  code: result.rewardReference ?? d['code']?.toString() ?? '',
                  percent: (d['percent'] as num?)?.toInt(),
                  maxDiscount: (d['max_discount'] as num?)?.toDouble() ??
                      result.rewardAmount,
                  minOrder: (d['min_order'] as num?)?.toDouble() ?? 0,
                  expiresAt: d['expires_at']?.toString(),
                  branchName: d['branch_name']?.toString(),
                  premium: result.rewardType == 'premium_coupon',
                ),
                const SizedBox(height: 10),
                const Text(
                  'محفوظة في حسابك: تظهر تلقائيًا في «كود الخصم» عند تأكيد الحجز.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ]);
        case 'coins':
          return _PrizeTile(
              icon: Icons.monetization_on_rounded,
              iconColor: _gold,
              title: '+${_money(result.rewardAmount)} كوينز',
              subtitle: 'أُضيفت إلى رصيدك الآن');
        default:
          return _PrizeTile(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xff7ee08a),
              title: '+${_money(result.rewardAmount)} د.ل',
              subtitle: d['description']?.toString() ?? 'أُضيف إلى حسابك');
      }
    }
    final String note;
    if (!result.won) {
      note = lostNote ?? 'الحارس كان أقوى هذه المرة. جرّب التسديد نحو الزوايا.';
    } else if (!result.rewardEligible) {
      note =
          'هذه محاولة تدريبية بلا جائزة. تفتح محاولتك المؤهلة التالية بعد انتهاء مدة الانتظار.';
    } else {
      note = 'فزت، لكن السحب لم يمنح جائزة هذه المرة. حظًا أوفر غدًا!';
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: Colors.white54),
        const SizedBox(width: 10),
        Expanded(
            child: Text(note,
                style: const TextStyle(color: Colors.white70, height: 1.4))),
      ]),
    );
  }
}

class _PrizeTile extends StatelessWidget {
  const _PrizeTile(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.subtitle});
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xff21402c), Color(0xff13261a)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: iconColor.withValues(alpha: .4)),
        ),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
        ]),
      );
}

/// A tear-off discount ticket: the stub carries the percentage, the body
/// the code and its terms.
class PenaltyCouponCard extends StatelessWidget {
  const PenaltyCouponCard({
    super.key,
    required this.code,
    required this.percent,
    required this.maxDiscount,
    required this.minOrder,
    required this.expiresAt,
    this.branchName,
    this.premium = false,
  });

  final String code;
  final int? percent;
  final double maxDiscount, minOrder;
  final String? expiresAt;

  /// Set when the admin locked this reward to one field.
  final String? branchName;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final terms = [
      if (maxDiscount > 0) 'حتى ${_money(maxDiscount)} د.ل',
      if (minOrder > 0) 'لطلب من ${_money(minOrder)} د.ل',
      if (branchName != null) 'في $branchName فقط',
      if (expiresAt != null) 'صالحة حتى $expiresAt',
      'استخدام واحد',
    ].join(' • ');

    return ClipPath(
      clipper: _TicketClipper(stubFraction: 0.32),
      child: Container(
        height: 164,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: premium
                ? const [
                    Color(0xff3a2a05),
                    Color(0xff8a6510),
                    Color(0xff3a2a05)
                  ]
                : const [Color(0xff0f3b20), _pitchGreen, Color(0xff0c2e18)],
          ),
        ),
        child: LayoutBuilder(builder: (context, box) {
          final stubW = box.maxWidth * 0.32;
          return Stack(children: [
            Positioned.fill(
                child: CustomPaint(painter: _TicketDetailPainter(stubW))),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: stubW,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(percent != null ? '$percent%' : 'خصم',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            color: _gold,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1)),
                    const SizedBox(height: 4),
                    const Text('خصم',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ]),
            ),
            Positioned(
              left: 14,
              top: 14,
              bottom: 12,
              right: stubW + 16,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(premium ? 'قسيمة ذهبية' : 'قسيمة حجز ملعب',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    _CodeChip(code: code),
                    const Spacer(),
                    Text(terms,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.35)),
                  ]),
            ),
          ]);
        }),
      ),
    );
  }
}

class _CodeChip extends StatefulWidget {
  const _CodeChip({required this.code});
  final String code;
  @override
  State<_CodeChip> createState() => _CodeChipState();
}

class _CodeChipState extends State<_CodeChip> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: widget.code));
          if (!mounted) return;
          setState(() => _copied = true);
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _gold.withValues(alpha: .6)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.code,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 17, color: _copied ? const Color(0xff7ee08a) : _gold),
          ]),
        ),
      );
}

class _TicketClipper extends CustomClipper<Path> {
  _TicketClipper({required this.stubFraction});
  final double stubFraction;

  @override
  Path getClip(Size size) {
    const r = 12.0, notch = 11.0;
    final x = size.width * (1 - stubFraction);
    final ticket = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(r)));
    final cuts = Path()
      ..addOval(Rect.fromCircle(center: Offset(x, 0), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(x, size.height), radius: notch));
    return Path.combine(PathOperation.difference, ticket, cuts);
  }

  @override
  bool shouldReclip(covariant _TicketClipper old) =>
      old.stubFraction != stubFraction;
}

class _TicketDetailPainter extends CustomPainter {
  _TicketDetailPainter(this.stubW);
  final double stubW;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width - stubW;
    final dash = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.4;
    for (var y = 14.0; y < size.height - 14; y += 9) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 4.5), dash);
    }
    // Faint pitch lines as a watermark on the body.
    final lines = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: .06)
      ..strokeWidth = 2;
    canvas.drawCircle(
        Offset(x * 0.5, size.height / 2), size.height * 0.36, lines);
    canvas.drawLine(Offset(x * 0.5, 0), Offset(x * 0.5, size.height), lines);
  }

  @override
  bool shouldRepaint(covariant _TicketDetailPainter old) => old.stubW != stubW;
}
