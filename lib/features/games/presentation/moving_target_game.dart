import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/games/data/moving_target_game_repo.dart';

const _green = Color(0xff3f8d4b);

class MovingTargetGameCard extends StatefulWidget {
  const MovingTargetGameCard({super.key});
  @override
  State<MovingTargetGameCard> createState() => _MovingTargetGameCardState();
}

class _MovingTargetGameCardState extends State<MovingTargetGameCard> {
  final _repo = getIt<MovingTargetGameRepo>();
  late Future<dynamic> _status;
  @override
  void initState() {
    super.initState();
    _status = _repo.status();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<dynamic>(
        future: _status,
        builder: (context, snapshot) {
          final value = snapshot.data?.fold((_) => null, (data) => data)
              as MovingGameStatus?;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GamesRewardsView())),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xff174c2b), Color(0xff3f8d4b)]),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x303f8d4b),
                        blurRadius: 16,
                        offset: Offset(0, 8))
                  ]),
              child: Row(children: [
                const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.sports_soccer,
                        size: 32, color: Colors.white)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('تحدي كابتن أيوب',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                          value?.rewardEligible == true
                              ? 'ألعاب حظ • فرصة مكافأة متاحة اليوم'
                              : 'ألعاب قصيرة • العب واربح',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ])),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white),
              ]),
            ),
          );
        },
      );
}

class GamesRewardsView extends StatefulWidget {
  const GamesRewardsView({super.key});
  @override
  State<GamesRewardsView> createState() => _GamesRewardsViewState();
}

class _GamesRewardsViewState extends State<GamesRewardsView> {
  final _statusFuture = getIt<MovingTargetGameRepo>().status();
  Timer? _cooldownTimer;
  int? _cooldownSeconds;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String _formatCooldown(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remaining = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xfff4f7f3),
        appBar: AppBar(
            title: const Text('مركز الألعاب والمكافآت'),
            backgroundColor: _green,
            foregroundColor: Colors.white),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          const Text('العب، تقدّم، واكسب',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff173a25))),
          const SizedBox(height: 6),
          const Text('تحديات عادلة ونتائج ومكافآت مسجلة على حسابك.'),
          const SizedBox(height: 18),
          BlocBuilder<CoinsCubit, CoinsState>(
              builder: (context, state) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                        color: const Color(0xfffff7dc),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(children: [
                      const Icon(Icons.monetization_on,
                          color: Color(0xffffb300)),
                      const SizedBox(width: 9),
                      const Text('رصيد الكوينز'),
                      const Spacer(),
                      Text('${state.balance?.coinsBalance ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.w800))
                    ]),
                  )),
          const SizedBox(height: 22),
          FutureBuilder<dynamic>(
              future: _statusFuture,
              builder: (context, snapshot) {
                final status = snapshot.data?.fold((_) => null, (data) => data)
                    as MovingGameStatus?;
                if (status == null) return const SizedBox.shrink();
                return _HowToEarnCard(status: status);
              }),
          const SizedBox(height: 22),
          const Text('تحديات تنتظرك',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FutureBuilder<dynamic>(
              future: _statusFuture,
              builder: (context, snapshot) {
                final status = snapshot.data?.fold((_) => null, (data) => data)
                    as MovingGameStatus?;
                if (status != null && _cooldownSeconds == null) {
                  _cooldownSeconds = status.cooldownSeconds;
                  if (_cooldownSeconds! > 0) {
                    _cooldownTimer = Timer.periodic(
                        const Duration(seconds: 1),
                        (_) => setState(() {
                              if (_cooldownSeconds! > 0) {
                                _cooldownSeconds = _cooldownSeconds! - 1;
                              }
                            }));
                  }
                }
                return Column(children: [
                  _FeaturedGameCard(
                      status: status,
                      cooldown: _formatCooldown(_cooldownSeconds ?? 0)),
                  const SizedBox(height: 14),
                  if (status != null)
                    ...status.availableGames.skip(1).map((game) =>
                        _LockedGameCard(
                            title: game.title,
                            subtitle: game.unlocked
                                ? game.gameType == 'cup_shuffle'
                                    ? 'اختر كوبًا واحدًا • حظًا موفقًا'
                                    : 'أدر العجلة واكتشف جائزتك'
                                : game.gameType == 'coming_soon'
                                    ? 'لعبة جديدة قيد التجهيز'
                                    : 'تفتح بعد ${game.unlockBookings} حجز مكتمل',
                            progress: {
                              'completed': status.completedBookings
                                  .clamp(0, game.unlockBookings),
                              'required': game.unlockBookings,
                              'progress': game.progress,
                            },
                            unlocked: game.unlocked,
                            onTap: game.unlocked
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => MovingTargetGamePage(
                                            gameKey: game.key,
                                            title: game.title,
                                            gameType: game.gameType,
                                            wheelOptions:
                                                status.rewardOptions)))
                                : null)),
                  _LockedGameCard(
                      title: 'إنجاز العميل الأسطوري',
                      subtitle: status?.legendaryVoucherCode != null
                          ? 'تهانينا! قسيمة الحجز المجاني: ${status!.legendaryVoucherCode}'
                          : status != null && status.legendaryVoucherAmount > 0
                              ? '100 حجز مكتمل • قسيمة ${status.legendaryVoucherAmount.toStringAsFixed(2)} د.ل'
                              : '100 حجز مكتمل • قسيمة يحددها Goal Master',
                      progress: status?.progression['legendary_customer']),
                ]);
              }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RewardHistoryPage())),
              icon: const Icon(Icons.history),
              label: const Text('سجل المكافآت')),
        ]),
      );
}

class _HowToEarnCard extends StatelessWidget {
  const _HowToEarnCard({required this.status});
  final MovingGameStatus status;

  String _rewardDescription(GameRewardOption reward) {
    switch (reward.type) {
      case 'coins':
        return reward.amount == null
            ? reward.title
            : '${reward.title}: ${reward.amount!.toStringAsFixed(0)} كوينز';
      case 'wallet_credit':
        return reward.amount == null
            ? reward.title
            : '${reward.title}: ${reward.amount!.toStringAsFixed(2)} د.ل للمحفظة';
      case 'coupon':
      case 'premium_coupon':
        final cap = (reward.maxDiscountAmount ?? 0) > 0
            ? '، بحد أقصى ${reward.maxDiscountAmount!.toStringAsFixed(2)} د.ل'
            : '';
        final minimum = (reward.minOrderValue ?? 0) > 0
            ? ' على طلب من ${reward.minOrderValue!.toStringAsFixed(2)} د.ل'
            : '';
        final expiry = reward.validityDays > 0
            ? '، صالحة ${reward.validityDays} يومًا'
            : '';
        return reward.amount == null
            ? reward.title
            : '${reward.title}: خصم ${reward.amount!.toStringAsFixed(0)}%$cap$minimum$expiry';
      case 'no_prize':
        return '${reward.title}: قد تجتاز التحدي دون جائزة';
      default:
        return reward.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligibility = !status.rewardSystemEnabled
        ? 'اللعب متاح، لكن سحب المكافآت متوقف حاليًا.'
        : !status.verified
            ? 'وثّق رقم هاتفك لتدخل سحب المكافآت.'
            : status.cooldownSeconds > 0
                ? 'المحاولة التدريبية متاحة، والمحاولة المؤهلة التالية بعد انتهاء الانتظار.'
                : !status.rewardBudgetAvailable
                    ? 'المكافآت غير متاحة مؤقتًا بعد بلوغ ميزانية اليوم.'
                    : status.rewardEligible
                        ? 'محاولتك التالية مؤهلة لسحب مكافأة.'
                        : 'يمكنك اللعب؛ أهلية المكافأة تعتمد على شروط الحساب والميزانية.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffdce9df)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.lightbulb_outline, color: _green),
          SizedBox(width: 8),
          Text('كيف تلعب وتكسب؟',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        const Text('١. أكمل الحجوزات المؤهلة لفتح المراحل التالية.'),
        const SizedBox(height: 5),
        const Text(
            '٢. اختر الكوب الذي تخفي تحته الكرة، أو أدر عجلة الحظ. نتيجة السحب يحددها الخادم وتظهر لك بوضوح.'),
        const SizedBox(height: 5),
        const Text(
            '٣. يلزم توثيق الهاتف للمحاولة المؤهلة. توجد محاولة مكافأة واحدة كل ٢٤ ساعة؛ المحاولات الأخرى للتدريب.'),
        const SizedBox(height: 10),
        Text(eligibility,
            style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
        if (status.rewardOptions.isNotEmpty) ...[
          const Divider(height: 22),
          const Text('الجوائز واحتمالاتها الحالية',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          ...status.rewardOptions.map((reward) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 42,
                        child: Text('${reward.probability}%',
                            style: const TextStyle(
                                color: _green, fontWeight: FontWeight.w800)),
                      ),
                      Expanded(child: Text(_rewardDescription(reward))),
                    ]),
              )),
          const SizedBox(height: 4),
          const Text(
              'النسبة فرصة في السحب وليست ضمانًا لجائزة محددة في كل مرة.',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ]),
    );
  }
}

class RewardHistoryPage extends StatelessWidget {
  const RewardHistoryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('سجل المكافآت'),
            backgroundColor: _green,
            foregroundColor: Colors.white),
        body: FutureBuilder<dynamic>(
          future: getIt<MovingTargetGameRepo>().rewardHistory(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data!.fold((_) => null, (items) => items)
                as List<Map<String, dynamic>>?;
            if (entries == null) {
              return const Center(child: Text('تعذر تحميل سجل المكافآت.'));
            }
            if (entries.isEmpty) {
              return const Center(
                  child: Text('لا توجد مكافآت مسجلة حتى الآن.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = entries[index];
                final details = item['details'] is Map
                    ? Map<String, dynamic>.from(item['details'])
                    : <String, dynamic>{};
                final amount = (item['amount'] as num?)?.toDouble() ?? 0;
                final type = item['reward_type']?.toString() ?? '';
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  leading: Icon(
                      type.contains('coupon')
                          ? Icons.confirmation_number_outlined
                          : Icons.card_giftcard,
                      color: _green),
                  title: Text(details['title']?.toString() ?? 'مكافأة اللعبة'),
                  subtitle: Text(
                      '${details['description'] ?? ''}${item['reference'] == null ? '' : '\n${item['reference']}'}\n${item['created_at'] ?? ''}'),
                  trailing: Text(
                      amount == 0
                          ? type
                          : '+${amount.toStringAsFixed(type == 'coins' ? 0 : 2)}${type == 'coins' ? ' كوينز' : ' د.ل'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: _green)),
                );
              },
            );
          },
        ),
      );
}

class _FeaturedGameCard extends StatelessWidget {
  const _FeaturedGameCard({required this.status, required this.cooldown});
  final MovingGameStatus? status;
  final String cooldown;
  @override
  Widget build(BuildContext context) {
    final challenge = status?.availableGames.isNotEmpty == true
        ? status!.availableGames.first
        : null;
    final durationSeconds = challenge?.durationSeconds ?? 30;
    final gameType = challenge?.gameType ?? 'cup_shuffle';
    final isWheel = gameType == 'reward_wheel';

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
                color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 5))
          ]),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff173e32),
                  Color(0xff2e754a),
                  Color(0xff163f32)
                ],
              ),
            ),
            child: Stack(children: [
              Positioned(
                  right: -22,
                  top: -54,
                  child: Icon(Icons.sports_soccer,
                      size: 180, color: Colors.white.withValues(alpha: .08))),
              Positioned(
                  left: 16,
                  top: 15,
                  child: Icon(
                      isWheel ? Icons.casino_outlined : Icons.sports_soccer,
                      size: 26,
                      color: const Color(0xffffd166).withValues(alpha: .9))),
              Positioned(
                  left: 18,
                  bottom: 18,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            isWheel
                                ? 'أدر العجلة واكتشف نتيجتك'
                                : 'راقب الأكواب واختر مكان الكرة',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 5),
                        Text(
                            isWheel
                                ? 'سحب واضح باحتمالات الجوائز المعتمدة'
                                : 'تحدٍّ سريع • ثلاث كؤوس • اختيار واحد',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ])),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Text(isWheel ? 'عجلة الحظ' : 'أين الكرة؟',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(isWheel
            ? 'أدر العجلة مرة واحدة. النتيجة واحتمالها يحددهما نظام المكافآت.'
            : 'تابع خلط الأكواب ثم اختر واحدًا. لا توجد أسئلة أو إجابات يمكن البحث عنها.'),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.timer_outlined, size: 18, color: _green),
          const SizedBox(width: 5),
          Expanded(
              child: Text(status != null &&
                      status!.cooldownSeconds > 0 &&
                      cooldown != '00:00:00'
                  ? 'فرصتك القادمة بعد $cooldown'
                  : '$durationSeconds ثانية')),
          const SizedBox(width: 6),
          if (status?.rewardEligible == true)
            Text('مكافأة من السحب اليومي',
                style:
                    const TextStyle(color: _green, fontWeight: FontWeight.bold))
          else if (status != null &&
              status!.cooldownSeconds > 0 &&
              cooldown != '00:00:00')
            const SizedBox.shrink()
          else
            const Text('محاولة تدريبية',
                style: TextStyle(color: Colors.black54))
        ]),
        const SizedBox(height: 14),
        SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    padding: const EdgeInsets.symmetric(vertical: 13)),
                onPressed: status?.enabled == false ||
                        (status != null &&
                            status!.availableGames.isNotEmpty &&
                            !status!.availableGames.first.isActive)
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MovingTargetGamePage(
                            gameKey: status?.availableGames.first.key ??
                                'moving_target',
                            title: status?.availableGames.first.title ??
                                'تحدي كابتن أيوب',
                            gameType: status?.availableGames.first.gameType ??
                                'cup_shuffle',
                            wheelOptions: status?.rewardOptions ?? const []))),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('ابدأ التحدي'))),
      ]),
    );
  }
}

class _LockedGameCard extends StatelessWidget {
  const _LockedGameCard(
      {required this.title,
      required this.subtitle,
      required this.progress,
      this.unlocked = false,
      this.onTap});
  final String title, subtitle;
  final Map<String, dynamic>? progress;
  final bool unlocked;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(unlocked ? Icons.play_circle_outline : Icons.lock_outline,
                color: unlocked ? _green : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                      value: (progress?['progress'] as num?)?.toDouble() ?? 0,
                      color: _green,
                      backgroundColor: const Color(0xffe7ece7))
                ])),
            const SizedBox(width: 8),
            Text(
                unlocked
                    ? 'العب'
                    : '${(progress?['completed'] as num?)?.toInt() ?? 0}/${(progress?['required'] as num?)?.toInt() ?? 0}',
                style: const TextStyle(color: Colors.grey, fontSize: 11))
          ])));
}

class MovingTargetGamePage extends StatefulWidget {
  const MovingTargetGamePage(
      {super.key,
      this.gameKey = 'moving_target',
      this.title = 'تحدي كابتن أيوب',
      this.gameType = 'cup_shuffle',
      this.wheelOptions = const []});
  final String gameKey, title, gameType;
  final List<GameRewardOption> wheelOptions;
  @override
  State<MovingTargetGamePage> createState() => _MovingTargetGamePageState();
}

class _MovingTargetGamePageState extends State<MovingTargetGamePage>
    with TickerProviderStateMixin {
  final _repo = getIt<MovingTargetGameRepo>();
  late final AnimationController _clock;
  late final AnimationController _motion;
  MovingGameAttempt? _attempt;
  MovingGameResult? _result;
  int _score = 0, _hits = 0;
  List<Map<String, dynamic>> _questions = const [];
  int _answeredCount = 0;
  int? _lastAnswer, _correctAnswer;
  bool? _lastWasCorrect;
  String? _explanation;
  bool _cupsReady = false, _wheelReady = false;
  bool _revealCupBall = true;
  int? _ballCupIdentity;
  final List<int> _cupPositions = [0, 1, 2];
  int? _wheelTargetIndex;
  double _wheelStopAngle = 0;
  bool _starting = true, _sending = false, _sound = true, _finishing = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _clock =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) _finish();
          });
    _motion = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3800));
    _start();
  }

  Future<void> _start() async {
    final res = await _repo.start(gameKey: widget.gameKey);
    if (!mounted) return;
    final value = res.fold((_) => null, (v) => v);
    if (value == null || value.id.isEmpty) {
      setState(() {
        _starting = false;
        _error = 'تعذر بدء التحدي. تحقق من الاتصال أو من إتاحة اللعبة.';
      });
      return;
    }
    setState(() {
      _attempt = value;
      _questions = value.questions;
      _starting = false;
    });
    _clock.duration = Duration(milliseconds: value.durationMs);
    if (value.gameType == 'cup_shuffle') {
      _clock.value =
          1 - (value.remainingMs.clamp(0, value.durationMs) / value.durationMs);
      _ballCupIdentity = value.cupStartIndex.clamp(0, 2);
      _clock.forward();
      _shuffleCups(value.cupSwaps);
    } else if (value.gameType == 'reward_wheel') {
      _clock.value =
          1 - (value.remainingMs.clamp(0, value.durationMs) / value.durationMs);
      _clock.forward();
      Future<void>.delayed(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _wheelReady = true);
      });
    } else {
      _clock.value =
          1 - (value.remainingMs.clamp(0, value.durationMs) / value.durationMs);
      _clock.forward();
    }
  }

  Future<void> _shuffleCups(List<List<int>> swaps) async {
    for (final swap in swaps) {
      if (!mounted || swap.length < 2) return;
      setState(() {
        for (var identity = 0; identity < _cupPositions.length; identity++) {
          if (_cupPositions[identity] == swap[0]) {
            _cupPositions[identity] = swap[1];
          } else if (_cupPositions[identity] == swap[1]) {
            _cupPositions[identity] = swap[0];
          }
        }
      });
      await Future<void>.delayed(const Duration(milliseconds: 470));
    }
    if (!mounted) return;
    setState(() {
      _revealCupBall = false;
      _cupsReady = true;
    });
  }

  String _uuid() {
    final random = math.Random.secure();
    String hex(int length) =>
        List.generate(length, (_) => random.nextInt(16).toRadixString(16))
            .join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  }

  Future<void> _finish() async {
    if (_finishing || _attempt == null) return;
    _finishing = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final res = await _repo.complete(_attempt!.id);
    if (!mounted) return;
    final value = res.fold((_) => null, (v) => v);
    setState(() {
      _finishing = false;
      if (value != null) {
        _result = value;
        _score = value.score;
        _hits = value.hits;
        _error = null;
      } else {
        _error = 'تعذر تأكيد النتيجة من الخادم. أعد المحاولة للتحقق من نتيجتك.';
      }
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    _motion.dispose();
    super.dispose();
  }

  Future<void> _chooseCup(int cupIndex) async {
    final attempt = _attempt;
    if (attempt == null || _sending || !_cupsReady || _finishing) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final response = await _repo.shot(
        attemptId: attempt.id, eventId: _uuid(), answerIndex: cupIndex);
    if (!mounted) return;
    final shot = response.fold((_) => null, (value) => value);
    if (shot == null) {
      setState(() {
        _sending = false;
        _error = 'تعذر تسجيل اختيارك. حاول مرة أخرى.';
      });
      return;
    }
    setState(() {
      _sending = false;
      _score = shot.score;
      _hits = shot.hits;
      _lastWasCorrect = shot.hit;
      _correctAnswer = shot.answerIndex;
      _revealCupBall = true;
    });
    if (_sound) SystemSound.play(SystemSoundType.click);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await _finish();
  }

  Future<void> _spinWheel() async {
    final attempt = _attempt;
    if (attempt == null ||
        _sending ||
        !_wheelReady ||
        _motion.isAnimating ||
        _finishing) {
      return;
    }
    final options = attempt.wheelOptions.isNotEmpty
        ? attempt.wheelOptions
        : widget.wheelOptions;
    if (options.isEmpty) {
      setState(() => _error = 'لا توجد جوائز مفعّلة للعجلة حاليًا.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final response = await _repo.shot(
        attemptId: attempt.id, eventId: _uuid(), wheelComplete: true);
    if (!mounted) return;
    final shot = response.fold((_) => null, (value) => value);
    if (shot == null || shot.wheelIndex == null) {
      setState(() {
        _sending = false;
        _error = 'تعذر بدء دوران العجلة. تحقق من الاتصال وحاول مجددًا.';
      });
      return;
    }
    final target = shot.wheelIndex!.clamp(0, options.length - 1);
    final total = options.fold<int>(0, (sum, item) => sum + item.probability);
    final before = options
        .take(target)
        .fold<int>(0, (sum, item) => sum + item.probability);
    final fraction = total > 0
        ? (before + options[target].probability / 2) / total
        : (target + .5) / options.length;
    setState(() {
      _sending = false;
      _wheelTargetIndex = target;
      _score = shot.score;
      _hits = shot.hits;
      _wheelStopAngle = math.pi * 12 - fraction * math.pi * 2;
    });
    _motion.duration = const Duration(milliseconds: 5200);
    await _motion.forward(from: 0);
    if (mounted) await _finish();
  }

  Future<void> _answerQuestion(int answerIndex) async {
    final attempt = _attempt;
    if (attempt == null ||
        _sending ||
        _clock.isCompleted ||
        _answeredCount >= _questions.length) {
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    if (_sound) SystemSound.play(SystemSoundType.click);
    final response = await _repo.shot(
      attemptId: attempt.id,
      eventId: _uuid(),
      scenarioIndex: _answeredCount,
      answerIndex: answerIndex,
    );
    if (!mounted) return;
    final answer = response.fold((_) => null, (value) => value);
    if (answer == null) {
      setState(() {
        _sending = false;
        _error = 'تعذر تسجيل الإجابة. تحقق من الاتصال وحاول مجددًا.';
      });
      return;
    }
    setState(() {
      _sending = false;
      _score = answer.score;
      _hits = answer.hits;
      _lastAnswer = answerIndex;
      _correctAnswer = answer.answerIndex;
      _lastWasCorrect = answer.hit;
      _explanation = answer.explanation;
    });
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    final finished = _answeredCount + 1 >= _questions.length;
    setState(() {
      _answeredCount++;
      _lastAnswer = null;
      _correctAnswer = null;
      _lastWasCorrect = null;
      _explanation = null;
    });
    if (finished) _finish();
  }

  Future<void> _skipQuestion() => _answerQuestion(-1);

  Widget _buildCupGame() => SafeArea(
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) {
            final seconds = ((_attempt?.durationMs ?? 15000) / 1000 -
                    (_clock.value * ((_attempt?.durationMs ?? 15000) / 1000)))
                .ceil()
                .clamp(0, 180);
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.visibility_outlined,
                      color: Color(0xffffd166)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    _cupsReady
                        ? 'أين تختبئ الكرة؟ اختر كوبًا واحدًا'
                        : 'راقب الكرة وهي تنتقل بين الأكواب',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
                  )),
                  Text('$seconds ث',
                      style: const TextStyle(
                          color: Color(0xffffd166),
                          fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    const cupWidth = 86.0;
                    final gap = (constraints.maxWidth - cupWidth * 3) / 4;
                    final ballSlot = _ballCupIdentity == null
                        ? -1
                        : _cupPositions[_ballCupIdentity!];
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xff1d6840), Color(0xff103a29)],
                        ),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Stack(clipBehavior: Clip.hardEdge, children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _StadiumPitchPainter()),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 38,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .36),
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        if (_revealCupBall && ballSlot >= 0)
                          Positioned(
                            left: gap * (ballSlot + 1) +
                                cupWidth * ballSlot +
                                cupWidth / 2 -
                                17,
                            bottom: 45,
                            child: const Icon(Icons.sports_soccer,
                                size: 34, color: Color(0xffffd166)),
                          ),
                        for (var identity = 0; identity < 3; identity++)
                          AnimatedPositioned(
                            key: ValueKey('cup-$identity'),
                            duration: const Duration(milliseconds: 430),
                            curve: Curves.easeInOutCubic,
                            left: gap * (_cupPositions[identity] + 1) +
                                cupWidth * _cupPositions[identity],
                            bottom: 62,
                            width: cupWidth,
                            height: 128,
                            child: GestureDetector(
                              onTap: _cupsReady && !_revealCupBall
                                  ? () => _chooseCup(_cupPositions[identity])
                                  : null,
                              child: _CupShape(
                                number: '${_cupPositions[identity] + 1}',
                                enabled: _cupsReady && !_sending && !_finishing,
                                revealBall: _revealCupBall &&
                                    _ballCupIdentity == identity,
                              ),
                            ),
                          ),
                        if (!_cupsReady && !_starting)
                          const Positioned(
                            top: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _GamePill(
                                  icon: Icons.sync, text: 'تابع حركة الأكواب'),
                            ),
                          ),
                        if (_sending)
                          const Positioned.fill(
                              child: ColoredBox(
                                  color: Color(0x55000000),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white)))),
                      ]),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  const Icon(Icons.shield_outlined,
                      color: Colors.white60, size: 18),
                  const SizedBox(width: 7),
                  Expanded(
                      child: Text(
                          _cupsReady
                              ? 'اختيار واحد فقط. يتم التحقق من النتيجة بأمان.'
                              : 'تبدأ فرصتك بعد انتهاء خلط الأكواب.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12))),
                  Text('$_hits إصابة',
                      style: const TextStyle(color: Colors.white70)),
                ]),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.amber))),
              ]),
            );
          },
        ),
      );

  Widget _buildWheelGame() => SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_clock, _motion]),
          builder: (context, _) {
            final options = _attempt?.wheelOptions.isNotEmpty == true
                ? _attempt!.wheelOptions
                : widget.wheelOptions;
            final durationSeconds = (_attempt?.durationMs ?? 15000) ~/ 1000;
            final seconds =
                (durationSeconds - (_clock.value * durationSeconds).floor())
                    .clamp(0, durationSeconds);
            final angle =
                _wheelStopAngle * Curves.easeOutCubic.transform(_motion.value);
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Column(children: [
                Row(children: [
                  const Icon(Icons.casino_outlined, color: Color(0xffffd166)),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Text('أدر العجلة واكتشف مكافأتك',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800))),
                  Text('$seconds ث',
                      style: const TextStyle(
                          color: Color(0xffffd166),
                          fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 8),
                const Text('فرص الفوز معتمدة من إعدادات المكافآت',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                if (_attempt?.rewardEligible != true)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: _GamePill(
                        icon: Icons.school_outlined,
                        text: 'محاولة تدريبية • لا تُصرف مكافأة'),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(alignment: Alignment.center, children: [
                        if (options.isNotEmpty)
                          AnimatedBuilder(
                            animation: _motion,
                            builder: (context, _) => CustomPaint(
                              size: Size.infinite,
                              painter: _PrizeWheelPainter(
                                  options: options, rotation: angle),
                            ),
                          )
                        else
                          const Center(
                              child: Text('لا توجد جوائز مفعّلة',
                                  style: TextStyle(color: Colors.white))),
                        const Positioned(
                          top: 0,
                          child: Icon(Icons.arrow_drop_down,
                              size: 54, color: Color(0xffffd166)),
                        ),
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                              color: const Color(0xffffd166),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 9)
                              ]),
                          child: const Icon(Icons.sports_soccer,
                              color: Color(0xff174c2b), size: 30),
                        ),
                      ]),
                    ),
                  ),
                ),
                if (_wheelTargetIndex != null &&
                    _wheelTargetIndex! < options.length)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      'النتيجة: ${options[_wheelTargetIndex!].title} • فرصة الظهور ${options[_wheelTargetIndex!].probability}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: _green, fontWeight: FontWeight.w800),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _wheelReady &&
                            !_sending &&
                            !_motion.isAnimating &&
                            !_finishing
                        ? _spinWheel
                        : null,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_arrow_rounded),
                    label: Text(_motion.isAnimating
                        ? 'العجلة تدور...'
                        : _wheelReady
                            ? 'أدر العجلة'
                            : 'تجهيز العجلة...'),
                    style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.amber))),
              ]),
            );
          },
        ),
      );

  Widget _buildQuizPlay() => SafeArea(
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) {
            final durationSeconds = (_attempt?.durationMs ?? 30000) ~/ 1000;
            final seconds =
                (durationSeconds - (_clock.value * durationSeconds).floor())
                    .clamp(0, durationSeconds);
            final hasQuestion = _answeredCount < _questions.length;
            final question = hasQuestion ? _questions[_answeredCount] : null;
            final options = (question?['options'] as List?) ?? const [];
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Column(children: [
                Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('نتيجتك',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('$_score',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900)),
                      ]),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(22)),
                    child: Row(children: [
                      const Icon(Icons.timer_outlined,
                          color: Color(0xffffd166), size: 18),
                      const SizedBox(width: 6),
                      Text('$seconds ث',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _questions.isEmpty
                        ? 0
                        : _answeredCount / _questions.length,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: const Color(0xffffd166),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xfff9fbf7),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 18,
                            offset: Offset(0, 8))
                      ],
                    ),
                    child: !hasQuestion
                        ? const Center(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Icon(Icons.emoji_events,
                                    color: Color(0xffd9a52d), size: 58),
                                SizedBox(height: 12),
                                Text('أكملت جميع الأسئلة',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              ]))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: const Color(0xffe5f1e6),
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: Text(
                                        '${_answeredCount + 1} / ${_questions.length}',
                                        style: const TextStyle(
                                            color: _green,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const Spacer(),
                                  Text(
                                      question?['category']?.toString() ??
                                          'كرة القدم',
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 12)),
                                ]),
                                const SizedBox(height: 18),
                                Text(question?['question']?.toString() ?? '',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Color(0xff173a25),
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        height: 1.45)),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: options.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 9),
                                    itemBuilder: (context, index) {
                                      final selected = _lastAnswer == index;
                                      final isCorrect =
                                          _correctAnswer == index &&
                                              _lastAnswer != null;
                                      final color = isCorrect
                                          ? const Color(0xffdaf0dc)
                                          : selected && _lastWasCorrect == false
                                              ? const Color(0xffffe2df)
                                              : Colors.white;
                                      return Material(
                                        color: color,
                                        borderRadius: BorderRadius.circular(15),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          onTap: _sending || _lastAnswer != null
                                              ? null
                                              : () => _answerQuestion(index),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 13, vertical: 13),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color: isCorrect
                                                        ? _green
                                                        : selected
                                                            ? Colors.redAccent
                                                            : const Color(
                                                                0xffe5e9e5))),
                                            child: Row(children: [
                                              CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: isCorrect
                                                      ? _green
                                                      : const Color(0xffedf1ed),
                                                  foregroundColor: isCorrect
                                                      ? Colors.white
                                                      : const Color(0xff56705b),
                                                  child: Text(
                                                      String.fromCharCode(
                                                          65 + index),
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              const SizedBox(width: 11),
                                              Expanded(
                                                  child: Text(
                                                      options[index].toString(),
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xff26352c),
                                                          fontWeight: FontWeight
                                                              .w600))),
                                              if (isCorrect)
                                                const Icon(Icons.check_circle,
                                                    color: _green, size: 19),
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (_lastAnswer != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                        color: _lastWasCorrect == true
                                            ? const Color(0xffe8f5e9)
                                            : const Color(0xfffff1df),
                                        borderRadius:
                                            BorderRadius.circular(13)),
                                    child: Text(
                                        '${_lastWasCorrect == true ? 'إجابة صحيحة' : 'الإجابة الصحيحة موضحة بالأخضر'}${_explanation == null || _explanation!.isEmpty ? '' : '\n$_explanation'}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            color: Color(0xff34473a),
                                            fontSize: 12,
                                            height: 1.45)),
                                  ),
                                if (_lastAnswer == null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed:
                                          _sending ? null : _skipQuestion,
                                      child: const Text('تخطّي السؤال'),
                                    ),
                                  ),
                              ]),
                  ),
                ),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(_error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.amber))),
              ]),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: const Color(0xff10251b),
      appBar: AppBar(
          backgroundColor: const Color(0xff10251b),
          foregroundColor: Colors.white,
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () => setState(() => _sound = !_sound),
                icon: Icon(_sound ? Icons.volume_up : Icons.volume_off))
          ]),
      body: _result != null
          ? _buildResult()
          : _starting
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _error != null && _attempt == null
                  ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center)))
                  : _attempt?.gameType == 'cup_shuffle'
                      ? _buildCupGame()
                      : _attempt?.gameType == 'reward_wheel'
                          ? _buildWheelGame()
                          : _buildQuizPlay());
  Widget _buildResult() => SafeArea(
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.emoji_events,
                    color: Color(0xffffca59), size: 76),
                const SizedBox(height: 18),
                Text(
                    _attempt?.gameType == 'reward_wheel'
                        ? 'اكتمل الدوران'
                        : _attempt?.gameType == 'cup_shuffle'
                            ? 'انتهى التحدي'
                            : 'انتهى الاختبار!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                    _attempt?.gameType == 'reward_wheel'
                        ? 'تم تسجيل نتيجة عجلة الحظ بأمان'
                        : _attempt?.gameType == 'cup_shuffle'
                            ? (_lastWasCorrect == true
                                ? 'أحسنت، اخترت الكوب الصحيح.'
                                : 'لم تكن الكرة تحت هذا الكوب هذه المرة.')
                            : '$_score نقطة  •  $_hits إجابة صحيحة من ${_questions.length}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 6),
                if (_attempt?.gameType == 'quiz')
                  Text(
                      'نقاط اجتياز هذا التحدي: ${_attempt?.winningScore ?? 300}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 15),
                if (_result!.rewardType != null &&
                    _result!.rewardType != 'no_prize')
                  Text(
                      'مبروك! ${_result!.rewardTitle ?? _result!.rewardDetails?['description'] ?? 'حصلت على مكافأة'}${_result!.rewardReference == null ? '' : '\nالرمز: ${_result!.rewardReference}'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xffffd66b),
                          fontSize: 16,
                          fontWeight: FontWeight.bold))
                else if (_result!.won && _result!.rewardEligible)
                  const Text(
                      'اجتزت شرط الفوز، لكن نتيجة السحب اليومي لم تتضمن جائزة هذه المرة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70))
                else if (_result!.won)
                  Text(
                      _attempt?.rewardEligible != true
                          ? 'هذه محاولة تدريبية؛ النتيجة لا تمنح مكافأة.'
                          : 'اجتزت التحدي. فرصة المكافأة التالية متاحة بعد انتهاء فترة الانتظار.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70))
                else
                  Text(
                      _attempt?.gameType == 'cup_shuffle'
                          ? 'حظ أوفر في المرة القادمة. يمكنك العودة وتجربة تحدٍّ آخر.'
                          : 'لم تصل إلى نقاط الفوز بعد. راجع إجاباتك وحاول في التحدي التالي.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('العودة للمركز'))
              ]))));
}

class _CupShape extends StatelessWidget {
  const _CupShape(
      {required this.number, required this.enabled, required this.revealBall});
  final String number;
  final bool enabled, revealBall;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : .94,
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Transform.translate(
            offset: revealBall ? const Offset(0, -26) : Offset.zero,
            child: CustomPaint(
                size: const Size(72, 91),
                painter: _CupPainter(selected: enabled)),
          ),
          const SizedBox(height: 4),
          Text('الكوب $number',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _GamePill extends StatelessWidget {
  const _GamePill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: const Color(0xffffd166), size: 16),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _CupPainter extends CustomPainter {
  const _CupPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(size.width * .12, size.height * .18)
      ..quadraticBezierTo(size.width * .5, size.height * .1, size.width * .88,
          size.height * .18)
      ..lineTo(size.width * .73, size.height * .91)
      ..quadraticBezierTo(
          size.width * .5, size.height, size.width * .27, size.height * .91)
      ..close();
    canvas.drawShadow(body, Colors.black.withValues(alpha: .38), 7, true);
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xffffd873), Color(0xffc98821)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawPath(body, fill);
    canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = selected ? Colors.white : const Color(0xffffedb4));
    canvas.drawOval(
        Rect.fromLTWH(size.width * .09, size.height * .1, size.width * .82,
            size.height * .16),
        Paint()..color = const Color(0xffffe8a5));
    canvas.drawLine(
        Offset(size.width * .29, size.height * .31),
        Offset(size.width * .25, size.height * .78),
        Paint()
          ..color = Colors.white.withValues(alpha: .45)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant _CupPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _StadiumPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .045);
    for (var i = 0; i < 8; i++) {
      final left = i * size.width / 8;
      if (i.isEven) {
        canvas.drawRect(
            Rect.fromLTWH(left, 0, size.width / 8, size.height), paint);
      }
    }
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(
        Rect.fromLTWH(size.width * .08, size.height * .12, size.width * .84,
            size.height * .73),
        line);
    canvas.drawCircle(
        Offset(size.width / 2, size.height * .5), size.width * .2, line);
    canvas.drawLine(Offset(size.width * .08, size.height * .5),
        Offset(size.width * .92, size.height * .5), line);
  }

  @override
  bool shouldRepaint(covariant _StadiumPitchPainter oldDelegate) => false;
}

class _PrizeWheelPainter extends CustomPainter {
  const _PrizeWheelPainter({required this.options, required this.rotation});
  final List<GameRewardOption> options;
  final double rotation;

  static const _colors = [
    Color(0xff18864b),
    Color(0xfff0ae35),
    Color(0xff3778c2),
    Color(0xffcf4b45),
    Color(0xff7c59a5),
    Color(0xff24a5a5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 9;
    final total = options.fold<int>(0, (sum, item) => sum + item.probability);
    if (total <= 0) return;
    var start = -math.pi / 2 + rotation;
    for (var i = 0; i < options.length; i++) {
      final sweep = math.pi * 2 * options[i].probability / total;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
          rect,
          start,
          sweep,
          true,
          Paint()
            ..color = _colors[i % _colors.length]
            ..style = PaintingStyle.fill);
      canvas.drawArc(
          rect,
          start,
          sweep,
          true,
          Paint()
            ..color = Colors.white.withValues(alpha: .8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      final mid = start + sweep / 2;
      final textCenter = Offset(center.dx + math.cos(mid) * radius * .66,
          center.dy + math.sin(mid) * radius * .66);
      final title = options[i].title.length > 15
          ? '${options[i].title.substring(0, 14)}…'
          : options[i].title;
      final paragraph = TextPainter(
        text: TextSpan(
            text: '$title\n${options[i].probability}%',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1.25,
                shadows: [Shadow(color: Colors.black45, blurRadius: 3)])),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        maxLines: 2,
      )..layout(maxWidth: radius * .48);
      canvas.save();
      canvas.translate(textCenter.dx, textCenter.dy);
      canvas.rotate(mid + math.pi / 2);
      paragraph.paint(
          canvas, Offset(-paragraph.width / 2, -paragraph.height / 2));
      canvas.restore();
      start += sweep;
    }
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = const Color(0xffffd166));
  }

  @override
  bool shouldRepaint(covariant _PrizeWheelPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.options != options;
}
