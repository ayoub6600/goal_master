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
      required this.legendaryVoucherAmount,
      required this.legendaryVoucherCode,
      required this.availableGames});
  final bool enabled;
  final bool rewardEligible;
  final double rewardAmount;
  final int cooldownSeconds;
  final int completedBookings;
  final Map<String, Map<String, dynamic>> progression;
  final double legendaryVoucherAmount;
  final String? legendaryVoucherCode;
  final List<GameChallengeStatus> availableGames;
}

class GameChallengeStatus {
  const GameChallengeStatus(
      {required this.key,
      required this.title,
      required this.description,
      required this.difficulty,
      required this.questionCount,
      required this.durationSeconds,
      required this.unlockBookings,
      required this.isActive,
      required this.unlocked,
      required this.progress});
  final String key, title, description, difficulty;
  final int questionCount, durationSeconds, unlockBookings;
  final bool isActive, unlocked;
  final double progress;
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
      required this.rewardAmount,
      required this.title});
  final String id;
  final String gameKey;
  final int durationMs;
  final int remainingMs;
  final List<double> phases;
  final List<Map<String, dynamic>> questions;
  final bool rewardEligible;
  final double rewardAmount;
  final String title;
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
      {required this.score,
      required this.hits,
      required this.rewardAmount,
      required this.won,
      required this.rewardEligible,
      this.rewardType,
      this.rewardTitle,
      this.rewardReference,
      this.rewardDetails});
  final int score;
  final int hits;
  final double rewardAmount;
  final bool won, rewardEligible;
  final String? rewardType, rewardTitle, rewardReference;
  final Map<String, dynamic>? rewardDetails;
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
            legendaryVoucherCode: (data['legendary_customer_achievement']
                    as Map?)?['voucher_code']
                ?.toString(),
            availableGames: ((data['available_games'] as List?) ?? const [])
                .whereType<Map>()
                .map((item) {
              final game = Map<String, dynamic>.from(item);
              return GameChallengeStatus(
                key: game['game_key']?.toString() ?? '',
                title: game['title']?.toString() ?? '',
                description: game['description']?.toString() ?? '',
                difficulty: game['difficulty']?.toString() ?? 'easy',
                questionCount: (game['question_count'] as num?)?.toInt() ?? 5,
                durationSeconds:
                    (game['duration_seconds'] as num?)?.toInt() ?? 30,
                unlockBookings: (game['unlock_bookings'] as num?)?.toInt() ?? 0,
                isActive: game['is_active'] == true,
                unlocked: game['unlocked'] == true,
                progress: (game['progress'] as num?)?.toDouble() ?? 0,
              );
            }).toList(),
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
            title: data['title']?.toString() ?? 'تحدي كابتن أيوب',
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
            won: data['won'] == true,
            rewardEligible: data['reward_eligible'] == true,
            rewardType: data['reward_type']?.toString(),
            rewardTitle: data['reward_title']?.toString(),
            rewardReference: data['reward_reference']?.toString(),
            rewardDetails: data['reward_details'] is Map
                ? Map<String, dynamic>.from(data['reward_details'])
                : null,
          );
        },
      );

  Future<Either<Failure, List<Map<String, dynamic>>>> rewardHistory() =>
      api.handleRequest(
        () => api.get('$_root/rewards/history'),
        (response) {
          final payload = Map<String, dynamic>.from(response['data'] ?? {});
          final rows = (payload['data'] as List?) ?? const [];
          return rows
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
        },
      );
}
