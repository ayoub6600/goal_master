import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/games/data/prediction_repo.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../keepy/captain_rig.dart';
import '../game_errors.dart';

const _bg = Color(0xff07110b);
const _card = Color(0xff112019);
const _gold = Color(0xffffc928);
const _mint = Color(0xff6ee7a8);

String _when(DateTime t) {
  final now = DateTime.now();
  final day = DateTime(t.year, t.month, t.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = day.difference(today).inDays;
  final time = DateFormat('HH:mm').format(t);
  if (diff == 0) return 'اليوم $time';
  if (diff == 1) return 'غدًا $time';
  if (diff == -1) return 'أمس $time';
  const days = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  return '${days[t.weekday - 1]} ${t.day}/${t.month} • $time';
}

String _countdown(Duration d) {
  if (d.inDays > 0) return '${d.inDays} يوم و ${d.inHours % 24} س';
  if (d.inHours > 0) return '${d.inHours} س ${d.inMinutes % 60} د';
  if (d.inMinutes > 0) return '${d.inMinutes} د ${d.inSeconds % 60} ث';
  return '${d.inSeconds} ث';
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key, this.repo});
  final PredictionRepo? repo;

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  late final PredictionRepo _repo = widget.repo ?? getIt<PredictionRepo>();
  PredictionBoard? _board;
  String? _error;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _load();
    // Countdowns, and locking cards the moment their match kicks off.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final res = await _repo.board();
    if (!mounted) return;
    res.fold((f) => setState(() => _error = friendlyGameError(f.errMessage)), (b) => setState(() => _board = b));
  }

  Future<bool> _predict(PredictionMatch m, int home, int away) async {
    final res = await _repo.predict(m.id, home, away);
    if (!mounted) return false;
    return res.fold((f) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.errMessage)));
      _load();
      return false;
    }, (updated) {
      final b = _board;
      if (b != null) {
        setState(() {
          _board = PredictionBoard(
            enabled: b.enabled,
            verified: b.verified,
            exactPoints: b.exactPoints,
            resultPoints: b.resultPoints,
            prizes: b.prizes,
            upcoming: [for (final x in b.upcoming) x.id == updated.id ? updated : x],
            recent: b.recent,
            week: b.week,
            lastWeek: b.lastWeek,
          );
        });
      }
      HapticFeedback.mediumImpact();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = _board;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          title: const Text('توقع النتيجة', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))],
          bottom: const TabBar(
            indicatorColor: _gold,
            labelColor: _gold,
            unselectedLabelColor: Colors.white60,
            labelStyle: TextStyle(fontWeight: FontWeight.w800),
            tabs: [Tab(text: 'المباريات'), Tab(text: 'النتائج'), Tab(text: 'الترتيب')],
          ),
        ),
        body: _error != null
            ? _Message(text: _error!, onRetry: _load)
            : b == null
                ? const Center(child: CircularProgressIndicator(color: _gold))
                : TabBarView(children: [
                    _MatchesTab(board: b, onPredict: _predict, onRefresh: _load),
                    _ResultsTab(board: b, onRefresh: _load),
                    _TableTab(board: b, onRefresh: _load),
                  ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatefulWidget {
  const _Header({required this.board});
  final PredictionBoard board;
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  ui.Image? _captain;

  @override
  void initState() {
    super.initState();
    CaptainArt.shared().then((a) {
      if (mounted) setState(() => _captain = a.wave);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.board;
    final medals = ['🥇', '🥈', '🥉'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff16402a), Color(0xff0f2a1c)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _mint.withValues(alpha: .25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        SizedBox(
          width: 70,
          height: 112,
          child: _captain == null ? null : RawImage(image: _captain, fit: BoxFit.contain, alignment: Alignment.bottomCenter),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('توقّع قبل صافرة البداية',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _Chip('النتيجة بالضبط +${b.exactPoints}', _gold),
              _Chip('الفائز الصحيح +${b.resultPoints}', _mint),
            ]),
            const SizedBox(height: 8),
            if (b.prizes.any((p) => p > 0))
              Text(
                'جوائز كل أسبوع: ${[for (var i = 0; i < b.prizes.length && i < 3; i++) if (b.prizes[i] > 0) '${medals[i]} ${b.prizes[i]}'].join('  ')} كوينز',
                style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
      );
}

class _MatchesTab extends StatelessWidget {
  const _MatchesTab({required this.board, required this.onPredict, required this.onRefresh});
  final PredictionBoard board;
  final Future<bool> Function(PredictionMatch, int, int) onPredict;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final b = board;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
        _Header(board: b),
        if (!b.enabled)
          const _Notice(icon: Icons.pause_circle_outline, text: 'التوقعات متوقفة مؤقتًا.')
        else if (!b.verified)
          const _Notice(icon: Icons.verified_user_outlined, text: 'وثّق رقم هاتفك لتشارك في التوقعات والجوائز.'),
        if (b.upcoming.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text('لا توجد مباريات للتوقع حاليًا. تابعنا قبل المباريات الكبيرة!',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, height: 1.5)),
          )
        else
          for (final m in b.upcoming)
            _MatchCard(key: ValueKey(m.id), match: m, canPredict: b.enabled && b.verified, onPredict: onPredict),
      ]),
    );
  }
}

class _MatchCard extends StatefulWidget {
  const _MatchCard({super.key, required this.match, required this.canPredict, required this.onPredict});
  final PredictionMatch match;
  final bool canPredict;
  final Future<bool> Function(PredictionMatch, int, int) onPredict;

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard> {
  late int _home = widget.match.mine?.home ?? 0;
  late int _away = widget.match.mine?.away ?? 0;
  bool _saving = false;

  @override
  void didUpdateWidget(covariant _MatchCard old) {
    super.didUpdateWidget(old);
    final mine = widget.match.mine;
    if (mine != null && mine != old.match.mine) {
      _home = mine.home;
      _away = mine.away;
    }
  }

  bool get _dirty {
    final mine = widget.match.mine;
    return mine == null || mine.home != _home || mine.away != _away;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final now = DateTime.now();
    final open = m.openAt(now) && widget.canPredict;
    final mine = m.mine;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: open ? _mint.withValues(alpha: .3) : Colors.white10),
      ),
      child: Column(children: [
        Row(children: [
          if (m.competition != null && m.competition!.isNotEmpty)
            Flexible(
              child: Text(m.competition!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          const Spacer(),
          Icon(Icons.schedule_rounded, size: 15, color: open ? _mint : Colors.white38),
          const SizedBox(width: 4),
          Text(_when(m.kickoff), style: TextStyle(color: open ? Colors.white : Colors.white54, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(child: _Team(name: m.home)),
          _Stepper(value: _home, enabled: open && !_saving, onChanged: (v) => setState(() => _home = v)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(':', style: TextStyle(color: Colors.white54, fontSize: 26, fontWeight: FontWeight.w900)),
          ),
          _Stepper(value: _away, enabled: open && !_saving, onChanged: (v) => setState(() => _away = v)),
          Expanded(child: _Team(name: m.away)),
        ]),
        const SizedBox(height: 12),
        if (open)
          Row(children: [
            Expanded(
              child: Text(
                'يُقفل التوقع بعد ${_countdown(m.locksAt.difference(now))}',
                style: const TextStyle(color: Colors.white60, fontSize: 12.5),
              ),
            ),
            if (mine != null && !_dirty)
              const Row(children: [
                Icon(Icons.check_circle_rounded, color: _mint, size: 18),
                SizedBox(width: 4),
                Text('تم حفظ توقعك', style: TextStyle(color: _mint, fontWeight: FontWeight.w800)),
              ])
            else
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onPredict(m, _home, _away);
                        if (mounted) setState(() => _saving = false);
                      },
                child: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(mine == null ? 'احفظ توقعك' : 'حدّث التوقع'),
              ),
          ])
        else
          Row(children: [
            const Icon(Icons.lock_rounded, size: 16, color: Colors.white38),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                !widget.canPredict
                    ? 'التوقع غير متاح لحسابك حاليًا'
                    : mine == null
                        ? 'انطلقت المباراة — لم تتوقع هذه المرة'
                        : 'انطلقت المباراة — توقعك ${mine.home} : ${mine.away}، بانتظار النتيجة',
                style: const TextStyle(color: Colors.white54, fontSize: 12.5),
              ),
            ),
          ]),
      ]),
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => Column(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white10,
          child: Text(name.isEmpty ? '?' : name.characters.first,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        ),
        const SizedBox(height: 6),
        Text(name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5, height: 1.25)),
      ]);
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.enabled, required this.onChanged});
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        _StepButton(icon: Icons.keyboard_arrow_up_rounded, onTap: enabled && value < 20 ? () => onChanged(value + 1) : null),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xff1b3326) : Colors.white.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('$value',
              style: TextStyle(color: enabled ? Colors.white : Colors.white54, fontSize: 28, fontWeight: FontWeight.w900)),
        ),
        _StepButton(icon: Icons.keyboard_arrow_down_rounded, onTap: enabled && value > 0 ? () => onChanged(value - 1) : null),
      ]);
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: 28, color: onTap == null ? Colors.white12 : Colors.white70),
        ),
      );
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab({required this.board, required this.onRefresh});
  final PredictionBoard board;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = board.recent;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Text('لا توجد نتائج بعد.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
          ),
        for (final m in list) _ResultCard(match: m),
      ]),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.match});
  final PredictionMatch match;

  @override
  Widget build(BuildContext context) {
    final m = match;
    final r = m.result!;
    final pts = m.points;
    final (Color color, String badge) = m.mine == null
        ? (Colors.white38, 'لم تتوقع')
        : m.exact
            ? (_gold, '+$pts بالضبط!')
            : (pts ?? 0) > 0
                ? (_mint, '+$pts')
                : (const Color(0xffff8a80), '0');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Text(m.home,
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
            child: Text('${r.home} - ${r.away}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          Expanded(
              child: Text(m.away,
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text(m.mine == null ? _when(m.kickoff) : 'توقعك: ${m.mine!.home} - ${m.mine!.away}',
              style: const TextStyle(color: Colors.white60, fontSize: 12.5)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)),
            child: Text(badge, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ),
        ]),
      ]),
    );
  }
}

class _TableTab extends StatelessWidget {
  const _TableTab({required this.board, required this.onRefresh});
  final PredictionBoard board;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
          _TableCard(title: 'ترتيب هذا الأسبوع', table: board.week),
          if (board.lastWeek.leaders.isNotEmpty) ...[
            const SizedBox(height: 14),
            _TableCard(title: 'الأسبوع الماضي', table: board.lastWeek, past: true),
          ],
        ]),
      );
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.title, required this.table, this.past = false});
  final String title;
  final PredictionTable table;
  final bool past;

  @override
  Widget build(BuildContext context) {
    const medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    final meInTop = table.leaders.any((l) => l.me);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          const Spacer(),
          Text('${table.start} ← ${table.end}', style: const TextStyle(color: Colors.white38, fontSize: 11.5)),
        ]),
        const SizedBox(height: 10),
        if (table.leaders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('لا نقاط بعد — أول نتيجة تفتح الترتيب.', style: TextStyle(color: Colors.white54)),
          ),
        for (final l in table.leaders)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: l.me ? _gold.withValues(alpha: .12) : Colors.white.withValues(alpha: .03),
              borderRadius: BorderRadius.circular(12),
              border: l.me ? Border.all(color: _gold.withValues(alpha: .5)) : null,
            ),
            child: Row(children: [
              SizedBox(
                width: 34,
                child: Text(medals[l.rank] ?? '${l.rank}',
                    style: const TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w900)),
              ),
              Expanded(
                child: Text(l.me ? '${l.name} (أنت)' : l.name,
                    style: TextStyle(color: Colors.white, fontWeight: l.me ? FontWeight.w900 : FontWeight.w700)),
              ),
              if (past && l.coins > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('+${l.coins} كوينز', style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              Text('${l.points} ن', style: const TextStyle(color: _mint, fontWeight: FontWeight.w900)),
            ]),
          ),
        if (!meInTop && table.myRank != null) ...[
          const Divider(color: Colors.white12),
          Text('ترتيبك: ${table.myRank} — ${table.myPoints} نقطة',
              style: const TextStyle(color: _gold, fontWeight: FontWeight.w800)),
        ],
        if (past && !table.awarded && table.leaders.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('الجوائز قيد الاعتماد من الإدارة.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
      ]),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff2a93b).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xfff2a93b).withValues(alpha: .35)),
        ),
        child: Row(children: [
          Icon(icon, color: const Color(0xfff2a93b)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xfff2a93b), fontWeight: FontWeight.w700))),
        ]),
      );
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
          ]),
        ),
      );
}
