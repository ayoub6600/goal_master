import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/games/data/moving_target_game_repo.dart';
import 'package:goal_master/features/games/presentation/cups/cup_game_page.dart';
import 'package:goal_master/features/games/presentation/keeper/goalkeeper_page.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_uppy_page.dart';
import 'package:goal_master/features/games/presentation/penalty/penalty_shootout_page.dart';
import 'package:goal_master/features/games/presentation/prediction/prediction_page.dart';

const _bg = Color(0xff07110b);
const _card = Color(0xff10201a);
const _gold = Color(0xffffc928);
const _mint = Color(0xff6ee7a8);
const _green = Color(0xff3f8d4b);

String _clock(int s) {
  final days = s ~/ 86400;
  final rest = s % 86400;
  final hms =
      '${(rest ~/ 3600).toString().padLeft(2, '0')}:${(rest % 3600 ~/ 60).toString().padLeft(2, '0')}:${(rest % 60).toString().padLeft(2, '0')}';
  return days > 0 ? '$days يوم و $hms' : hms;
}

/// Home-screen entry to the games.
class MovingTargetGameCard extends StatefulWidget {
  const MovingTargetGameCard({super.key});
  @override
  State<MovingTargetGameCard> createState() => _MovingTargetGameCardState();
}

class _MovingTargetGameCardState extends State<MovingTargetGameCard> {
  late final Future<dynamic> _status = getIt<MovingTargetGameRepo>().status();

  @override
  Widget build(BuildContext context) => FutureBuilder<dynamic>(
        future: _status,
        builder: (context, snapshot) {
          final value = snapshot.data?.fold((_) => null, (data) => data) as MovingGameStatus?;
          final chance = value != null && value.verified && value.cooldownSeconds == 0 && value.rewardSystemEnabled;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GamesRewardsView())),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xff123b24), Color(0xff2f7a43)]),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [BoxShadow(color: Color(0x303f8d4b), blurRadius: 16, offset: Offset(0, 8))]),
              child: Row(children: [
                const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.sports_soccer, size: 32, color: Colors.white)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('ألعاب كابتن أيوب',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(chance ? 'عندك فرصة جائزة الآن 🎁 • 5 ألعاب كرة' : 'ركلات ترجيح • حارس • تنطيط • أكواب • توقعات',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
              ]),
            ),
          );
        },
      );
}

/// The games hub: what you can play, what you can win, and when.
class GamesRewardsView extends StatefulWidget {
  const GamesRewardsView({super.key});
  @override
  State<GamesRewardsView> createState() => _GamesRewardsViewState();
}

class _GamesRewardsViewState extends State<GamesRewardsView> {
  final _repo = getIt<MovingTargetGameRepo>();
  MovingGameStatus? _status;
  Timer? _timer;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await _repo.status();
    if (!mounted) return;
    final s = res.fold((_) => null, (v) => v);
    _timer?.cancel();
    setState(() {
      _status = s;
      _cooldown = s?.cooldownSeconds ?? 0;
    });
    if (_cooldown > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _cooldown = _cooldown > 0 ? _cooldown - 1 : 0);
      });
    }
  }

  Future<void> _go(Widget page) async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    final cups = s?.availableGames.where((g) => g.gameType == 'cup_shuffle' && g.isActive).toList() ?? const [];
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('ألعاب كابتن أيوب', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'سجل المكافآت',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RewardHistoryPage())),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), children: [
          _PrizeStatus(status: s, cooldown: _cooldown),
          const SizedBox(height: 14),
          const _HowItWorks(),
          const SizedBox(height: 20),
          const Text('اختر لعبتك',
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _GameTile(
            title: 'ركلات الترجيح',
            text: 'اسحب من الكرة نحو الزاوية وتفوّق على الحارس.',
            icon: Icons.sports_soccer,
            color: const Color(0xffffc928),
            tag: 'مهارة',
            onTap: () => _go(const PenaltyShootoutPage()),
          ),
          _GameTile(
            title: 'كن الحارس',
            text: 'انت الحارس: اقرأ التسديدة وارتمِ في الزاوية الصح.',
            icon: Icons.sports_handball_rounded,
            color: _mint,
            tag: 'جديد',
            onTap: () => _go(const GoalkeeperPage()),
          ),
          _GameTile(
            title: 'تنطيط الكرة',
            text: 'ميّل الجوال وخلّ كابتن أيوب ينطّط الكرة بدون ما تطيح.',
            icon: Icons.sports_volleyball_rounded,
            color: const Color(0xff7fd3ff),
            tag: 'تركيز',
            onTap: () => _go(const KeepyUppyPage()),
          ),
          if (cups.isNotEmpty)
            _GameTile(
              title: 'تحدي الأكواب',
              text: 'تابع الكوب اللي فيه الكرة وهو يتخلط… واختار صح.',
              icon: Icons.local_drink_rounded,
              color: const Color(0xffff9f43),
              tag: cups.first.unlocked ? 'سريعة' : 'تُفتح بعد ${cups.first.unlockBookings} حجز',
              locked: !cups.first.unlocked,
              onTap: cups.first.unlocked
                  ? () => _go(CupGamePage(gameKey: cups.first.key, title: cups.first.title))
                  : null,
            ),
          _GameTile(
            title: 'توقع النتيجة',
            text: 'توقّع نتائج المباريات قبل انطلاقها وتصدّر ترتيب الأسبوع.',
            icon: Icons.scoreboard_rounded,
            color: const Color(0xffc9a7ff),
            tag: 'كل أسبوع',
            onTap: () => _go(const PredictionPage()),
          ),
          const SizedBox(height: 10),
          if (s != null) _Legendary(status: s),
          const SizedBox(height: 10),
          BlocBuilder<CoinsCubit, CoinsState>(
            builder: (context, state) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.monetization_on, color: Color(0xffffb300)),
                const SizedBox(width: 9),
                const Text('رصيد الكوينز', style: TextStyle(color: Colors.white70)),
                const Spacer(),
                Text('${state.balance?.coinsBalance ?? 0}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// One line that answers "can I win something right now?".
class _PrizeStatus extends StatelessWidget {
  const _PrizeStatus({required this.status, required this.cooldown});
  final MovingGameStatus? status;
  final int cooldown;

  @override
  Widget build(BuildContext context) {
    final s = status;
    final (IconData icon, Color color, String title, String text) = s == null
        ? (Icons.sports_soccer, Colors.white60, 'العب واربح', 'ألعاب كرة قصيرة، وجوائز كوينز وأكواد خصم على حجوزاتك.')
        : !s.enabled
            ? (Icons.pause_circle_outline, Colors.white54, 'الألعاب متوقفة مؤقتًا', 'ارجع لاحقًا.')
            : !s.rewardSystemEnabled
                ? (Icons.sports_esports_rounded, Colors.white70, 'وضع اللعب للمتعة', 'الجوائز متوقفة حاليًا، لكن تقدر تلعب وتتدرب.')
                : !s.verified
                    ? (Icons.verified_user_outlined, const Color(0xfff2a93b), 'وثّق رقم هاتفك',
                        'التوثيق شرط لدخول سحب الجوائز. اللعب نفسه متاح.')
                    : cooldown > 0
                        ? (Icons.timer_outlined, Colors.white, 'فرصة الجائزة القادمة بعد ${_clock(cooldown)}',
                            'لكل حساب فرصة جائزة واحدة في الفترة، مشتركة بين كل الألعاب. الآن تقدر تتدرب.')
                        : (Icons.card_giftcard_rounded, _gold, 'عندك فرصة جائزة الآن 🎁',
                            'أول جولة تلعبها في أي لعبة تدخل السحب لو فزت فيها.');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: .16), color.withValues(alpha: .05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (Icons.sports_esports_rounded, 'اختار لعبة'),
      (Icons.emoji_events_rounded, 'فوز بالتحدي'),
      (Icons.redeem_rounded, 'الجائزة في حسابك'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Row(children: [
          for (var i = 0; i < steps.length; i++) ...[
            Expanded(
              child: Column(children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: _gold.withValues(alpha: .14),
                  child: Icon(steps[i].$1, color: _gold, size: 22),
                ),
                const SizedBox(height: 6),
                Text(steps[i].$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
              ]),
            ),
            if (i < steps.length - 1) const Icon(Icons.chevron_left_rounded, color: Colors.white24),
          ],
        ]),
        const SizedBox(height: 10),
        const Text(
          'الجوائز كوينز أو أكواد خصم. كود الخصم يظهر لك تلقائيًا في «كود الخصم» لما تأكد حجزك.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.45),
        ),
      ]),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({
    required this.title,
    required this.text,
    required this.icon,
    required this.color,
    required this.tag,
    this.onTap,
    this.locked = false,
  });
  final String title, text, tag;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: locked ? .1 : .3)),
              ),
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withValues(alpha: .35), color.withValues(alpha: .12)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: locked ? Colors.white38 : color, size: 30),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(
                        child: Text(title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: locked ? Colors.white54 : Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(8)),
                        child: Text(tag, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.35)),
                  ]),
                ),
                const SizedBox(width: 6),
                Icon(locked ? Icons.lock_rounded : Icons.play_circle_fill_rounded,
                    color: locked ? Colors.white24 : color, size: 32),
              ]),
            ),
          ),
        ),
      );
}

class _Legendary extends StatelessWidget {
  const _Legendary({required this.status});
  final MovingGameStatus status;

  @override
  Widget build(BuildContext context) {
    final p = status.progression['legendary_customer'];
    final done = (p?['completed'] as num?)?.toInt() ?? status.completedBookings;
    final need = (p?['required'] as num?)?.toInt() ?? 100;
    final code = status.legendaryVoucherCode;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.workspace_premium_rounded, color: _gold),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('العميل الأسطوري',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15))),
          Text('$done / $need حجز', style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
              value: need > 0 ? (done / need).clamp(0.0, 1.0) : 0,
              minHeight: 7,
              backgroundColor: Colors.white10,
              color: _gold),
        ),
        const SizedBox(height: 8),
        Text(
          code != null
              ? 'مبروك! قسيمة الحجز المجاني: $code'
              : status.legendaryVoucherAmount > 0
                  ? 'أكمل $need حجز واربح قسيمة بقيمة ${status.legendaryVoucherAmount.toStringAsFixed(2)} د.ل'
                  : 'أكمل $need حجز واربح قسيمة من Goal Master',
          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
        ),
      ]),
    );
  }
}

class RewardHistoryPage extends StatelessWidget {
  const RewardHistoryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('سجل المكافآت'), backgroundColor: _green, foregroundColor: Colors.white),
        body: FutureBuilder<dynamic>(
          future: getIt<MovingTargetGameRepo>().rewardHistory(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data!.fold((_) => null, (items) => items) as List<Map<String, dynamic>>?;
            if (entries == null) {
              return const Center(child: Text('تعذر تحميل سجل المكافآت.'));
            }
            if (entries.isEmpty) {
              return const Center(child: Text('لا توجد مكافآت مسجلة حتى الآن.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = entries[index];
                final details = item['details'] is Map ? Map<String, dynamic>.from(item['details']) : <String, dynamic>{};
                final amount = (item['amount'] as num?)?.toDouble() ?? 0;
                final type = item['reward_type']?.toString() ?? '';
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(type.contains('coupon') ? Icons.confirmation_number_outlined : Icons.card_giftcard,
                      color: _green),
                  title: Text(details['title']?.toString() ?? 'مكافأة اللعبة'),
                  subtitle: Text(
                      '${details['description'] ?? ''}${item['reference'] == null ? '' : '\n${item['reference']}'}\n${item['created_at'] ?? ''}'),
                  trailing: Text(
                      amount == 0
                          ? type
                          : '+${amount.toStringAsFixed(type == 'coins' ? 0 : 2)}${type == 'coins' ? ' كوينز' : ' د.ل'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _green)),
                );
              },
            );
          },
        ),
      );
}
