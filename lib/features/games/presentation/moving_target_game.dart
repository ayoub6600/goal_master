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
                              ? 'اختبار معلومات كرة القدم • جائزة متاحة اليوم'
                              : 'اختبار كروي قصير • 5 أسئلة',
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
                                ? '${game.questionCount} سؤال • ${game.durationSeconds} ثانية • ${game.difficulty == 'hard' ? 'صعب' : 'متوسط'}'
                                : 'يفتح بعد ${game.unlockBookings} حجز مكتمل',
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
                                            title: game.title)))
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
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 5))
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
                    child: Icon(Icons.quiz_outlined,
                        size: 26,
                        color: const Color(0xffffd166).withValues(alpha: .9))),
                const Positioned(
                    left: 18,
                    bottom: 18,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اقرأ السؤال. اختر الإجابة.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                          SizedBox(height: 5),
                          Text('اختبار كروي قصير من 5 أسئلة',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ])),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          const Text('اختبار معلومات كرة القدم',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('خمسة أسئلة كروية سريعة. تعلّم من الإجابة واكسب نقاطًا.'),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.timer_outlined, size: 18, color: _green),
            const SizedBox(width: 5),
            Expanded(
                child: Text(status != null &&
                        status!.cooldownSeconds > 0 &&
                        cooldown != '00:00:00'
                    ? 'فرصتك القادمة بعد $cooldown'
                    : '30 ثانية')),
            const SizedBox(width: 6),
            if (status?.rewardEligible == true)
              Text('مكافأة من السحب اليومي',
                  style: const TextStyle(
                      color: _green, fontWeight: FontWeight.bold))
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
                                  'تحدي كابتن أيوب'))),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('ابدأ التحدي'))),
        ]),
      );
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
      this.title = 'تحدي كابتن أيوب'});
  final String gameKey, title;
  @override
  State<MovingTargetGamePage> createState() => _MovingTargetGamePageState();
}

class _MovingTargetGamePageState extends State<MovingTargetGamePage>
    with SingleTickerProviderStateMixin {
  final _repo = getIt<MovingTargetGameRepo>();
  late final AnimationController _clock;
  MovingGameAttempt? _attempt;
  MovingGameResult? _result;
  int _score = 0, _hits = 0;
  List<Map<String, dynamic>> _questions = const [];
  int _answeredCount = 0;
  int? _lastAnswer, _correctAnswer;
  bool? _lastWasCorrect;
  String? _explanation;
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
    _clock.value =
        1 - (value.remainingMs.clamp(0, value.durationMs) / value.durationMs);
    _clock.forward();
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
    super.dispose();
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
                  : _buildQuizPlay());
  Widget _buildResult() => SafeArea(
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.emoji_events,
                    color: Color(0xffffca59), size: 76),
                const SizedBox(height: 18),
                Text('انتهى الاختبار!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                    '$_score نقطة  •  $_hits إجابة صحيحة من ${_questions.length}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 18)),
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
                  const Text(
                      'اجتزت التحدي. فرصة المكافأة التالية متاحة بعد انتهاء فترة الانتظار.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70))
                else
                  const Text(
                      'لم تصل إلى نقاط الفوز بعد. راجع إجاباتك وحاول في التحدي التالي.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('العودة للمركز'))
              ]))));
}
