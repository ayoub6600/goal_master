import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/errors/failure.dart';

class MovingGameStatus {
  const MovingGameStatus(
      {required this.enabled,
      required this.rewardEligible,
      required this.rewardAmount,
      required this.cooldownSeconds,
      required this.completedBookings,
      required this.progression,
      required this.legendaryVoucherAmount});
  final bool enabled;
  final bool rewardEligible;
  final double rewardAmount;
  final int cooldownSeconds;
  final int completedBookings;
  final Map<String, Map<String, dynamic>> progression;
  final double legendaryVoucherAmount;
}

class MovingGameAttempt {
  const MovingGameAttempt(
      {required this.id,
      required this.gameKey,
      required this.durationMs,
      required this.remainingMs,
      required this.phases,
      required this.questions,
      required this.rewardEligible,
      required this.rewardAmount});
  final String id;
  final String gameKey;
  final int durationMs;
  final int remainingMs;
  final List<double> phases;
  final List<Map<String, dynamic>> questions;
  final bool rewardEligible;
  final double rewardAmount;
}

class MovingGameShot {
  const MovingGameShot(
      {required this.hit,
      required this.score,
      required this.hits,
      required this.points,
      this.answerIndex,
      this.explanation,
      this.currentLane = 1,
      this.dodges = 0,
      this.collisions = 0});
  final bool hit;
  final int score;
  final int hits;
  final int points;
  final int? answerIndex;
  final String? explanation;
  final int currentLane;
  final int dodges;
  final int collisions;
}

class MovingGameResult {
  const MovingGameResult(
      {required this.score, required this.hits, required this.rewardAmount});
  final int score;
  final int hits;
  final double rewardAmount;
}

class MovingTargetGameRepo {
  MovingTargetGameRepo(this.api);
  final ApiConsumer api;
  static const _root = 'user/games/moving-target';

  Future<Either<Failure, MovingGameStatus>> status() => api.handleRequest(
        () => api.get('$_root/'),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return MovingGameStatus(
            enabled: data['enabled'] == true,
            rewardEligible: data['reward_eligible'] == true,
            rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
            cooldownSeconds: (data['cooldown_seconds'] as num?)?.toInt() ?? 0,
            completedBookings:
                (data['completed_bookings'] as num?)?.toInt() ?? 0,
            progression: Map<String, Map<String, dynamic>>.fromEntries(
              (data['progression'] as Map? ?? const {})
                  .entries
                  .map((entry) => MapEntry(
                        entry.key.toString(),
                        Map<String, dynamic>.from(entry.value as Map),
                      )),
            ),
            legendaryVoucherAmount:
                (data['legendary_voucher_amount'] as num?)?.toDouble() ?? 0,
          );
        },
      );

  Future<Either<Failure, MovingGameAttempt>> start(
          {String gameKey = 'moving_target'}) =>
      api.handleRequest(
        () => api.post('$_root/start',
            isFormData: false, data: {'game_key': gameKey}),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return MovingGameAttempt(
            id: data['attempt_id']?.toString() ?? '',
            gameKey: data['game_key']?.toString() ?? gameKey,
            durationMs: (data['duration_ms'] as num?)?.toInt() ?? 30000,
            remainingMs: (data['remaining_ms'] as num?)?.toInt() ??
                (data['duration_ms'] as num?)?.toInt() ??
                30000,
            phases: ((data['target_phases'] as List?) ?? const [])
                .whereType<num>()
                .map((e) => e.toDouble())
                .toList(),
            questions: ((data['target_phases'] as List?) ?? const [])
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
            rewardEligible: data['reward_eligible'] == true,
            rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
          );
        },
      );

  Future<Either<Failure, MovingGameShot>> shot(
          {required String attemptId,
          required String eventId,
          int? scenarioIndex,
          int? answerIndex,
          int? lane,
          double? x,
          double? y}) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/shot', isFormData: false, data: {
          'event_uuid': eventId,
          if (scenarioIndex != null) 'scenario_index': scenarioIndex,
          if (answerIndex != null) 'answer_index': answerIndex,
          if (lane != null) 'lane': lane,
          if (x != null) 'aim_x': x,
          if (y != null) 'aim_y': y,
        }),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return MovingGameShot(
            hit: data['hit'] == true || data['correct'] == true,
            score: (data['score'] as num?)?.toInt() ?? 0,
            hits: (data['hits'] as num?)?.toInt() ?? 0,
            points: (data['points'] as num?)?.toInt() ?? 0,
            answerIndex: (data['answer_index'] as num?)?.toInt(),
            explanation: data['explanation']?.toString(),
            currentLane: (data['current_lane'] as num?)?.toInt() ?? 1,
            dodges: (data['dodges'] as num?)?.toInt() ?? 0,
            collisions: (data['collisions'] as num?)?.toInt() ?? 0,
          );
        },
      );

  Future<Either<Failure, MovingGameResult>> complete(String attemptId) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/complete', isFormData: false),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return MovingGameResult(
            score: (data['score'] as num?)?.toInt() ?? 0,
            hits: (data['hits'] as num?)?.toInt() ?? 0,
            rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
          );
        },
      );
}
