import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/errors/failure.dart';

int _int(Object? v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;

typedef Score = ({int home, int away});

Score? _score(Object? v) =>
    v is Map ? (home: _int(v['home']), away: _int(v['away'])) : null;

class PredictionMatch {
  const PredictionMatch({
    required this.id,
    required this.home,
    required this.away,
    required this.competition,
    required this.kickoff,
    required this.open,
    required this.locksAt,
    required this.status,
    required this.result,
    required this.mine,
    required this.points,
    required this.exact,
  });

  /// [received] is when the response arrived, so the lock countdown follows
  /// the server's clock rather than the phone's.
  factory PredictionMatch.fromJson(Map<String, dynamic> j, DateTime received) => PredictionMatch(
        id: _int(j['id']),
        home: j['home']?.toString() ?? '',
        away: j['away']?.toString() ?? '',
        competition: j['competition']?.toString(),
        kickoff: DateTime.tryParse(j['kickoff_at']?.toString() ?? '')?.toLocal() ?? received,
        open: j['open'] == true,
        locksAt: received.add(Duration(seconds: _int(j['locks_in_seconds']))),
        status: j['status']?.toString() ?? 'scheduled',
        result: _score(j['result']),
        mine: _score(j['mine']),
        points: (j['points'] as num?)?.toInt(),
        exact: j['exact'] == true,
      );

  final int id;
  final String home, away, status;
  final String? competition;
  final DateTime kickoff, locksAt;
  final bool open, exact;
  final Score? result, mine;
  final int? points;

  bool openAt(DateTime now) => open && now.isBefore(locksAt);
}

class PredictionLeader {
  const PredictionLeader({required this.rank, required this.name, required this.points, required this.exact, required this.me, required this.coins});
  final int rank, points, exact, coins;
  final String name;
  final bool me;
}

class PredictionTable {
  const PredictionTable({required this.start, required this.end, required this.awarded, required this.leaders, required this.myRank, required this.myPoints});

  factory PredictionTable.fromJson(Map<String, dynamic> j) {
    final me = j['me'] is Map ? Map<String, dynamic>.from(j['me']) : null;
    return PredictionTable(
      start: j['start']?.toString() ?? '',
      end: j['end']?.toString() ?? '',
      awarded: j['awarded'] == true,
      leaders: ((j['leaders'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => PredictionLeader(
                rank: _int(e['rank']),
                name: e['name']?.toString() ?? '',
                points: _int(e['points']),
                exact: _int(e['exact']),
                me: e['me'] == true,
                coins: _int(e['coins']),
              ))
          .toList(),
      myRank: me == null ? null : _int(me['rank']),
      myPoints: me == null ? 0 : _int(me['points']),
    );
  }

  final String start, end;
  final bool awarded;
  final List<PredictionLeader> leaders;
  final int? myRank;
  final int myPoints;
}

class PredictionBoard {
  const PredictionBoard({
    required this.enabled,
    required this.verified,
    required this.exactPoints,
    required this.resultPoints,
    required this.prizes,
    required this.upcoming,
    required this.recent,
    required this.week,
    required this.lastWeek,
  });

  final bool enabled, verified;
  final int exactPoints, resultPoints;
  final List<int> prizes;
  final List<PredictionMatch> upcoming, recent;
  final PredictionTable week, lastWeek;
}

class PredictionRepo {
  PredictionRepo(this.api);
  final ApiConsumer api;
  static const _root = 'user/games/predictions';

  Future<Either<Failure, PredictionBoard>> board() => api.handleRequest(
        () => api.get(_root),
        (response) {
          final received = DateTime.now();
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          final rules = Map<String, dynamic>.from(d['rules'] ?? {});
          List<PredictionMatch> list(Object? v) => ((v as List?) ?? const [])
              .whereType<Map>()
              .map((e) => PredictionMatch.fromJson(Map<String, dynamic>.from(e), received))
              .toList();
          return PredictionBoard(
            enabled: d['enabled'] == true,
            verified: d['verified'] == true,
            exactPoints: _int(rules['exact'], 3),
            resultPoints: _int(rules['result'], 1),
            prizes: ((d['prizes'] as List?) ?? const []).map((e) => _int(e)).toList(),
            upcoming: list(d['upcoming']),
            recent: list(d['recent']),
            week: PredictionTable.fromJson(Map<String, dynamic>.from(d['week'] ?? {})),
            lastWeek: PredictionTable.fromJson(Map<String, dynamic>.from(d['last_week'] ?? {})),
          );
        },
      );

  Future<Either<Failure, PredictionMatch>> predict(int matchId, int home, int away) => api.handleRequest(
        () => api.post('$_root/$matchId', isFormData: false, data: {'home': home, 'away': away}),
        (response) => PredictionMatch.fromJson(Map<String, dynamic>.from(response['data'] ?? {}), DateTime.now()),
      );
}
