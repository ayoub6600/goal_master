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
      required this.verified,
      required this.rewardSystemEnabled,
      required this.rewardBudgetAvailable,
      required this.rewardOptions,
      required this.availableGames});
  final bool enabled;
  final bool rewardEligible;
  final double rewardAmount;
  final int cooldownSeconds;
  final int completedBookings;
  final Map<String, Map<String, dynamic>> progression;
  final double legendaryVoucherAmount;
  final String? legendaryVoucherCode;
  final bool verified, rewardSystemEnabled, rewardBudgetAvailable;
  final List<GameRewardOption> rewardOptions;
  final List<GameChallengeStatus> availableGames;
}

class GameRewardOption {
  const GameRewardOption({
    required this.type,
    required this.title,
    required this.probability,
    required this.amount,
    required this.maxDiscountAmount,
    required this.minOrderValue,
    required this.validityDays,
  });

  final String type, title;
  final int probability, validityDays;
  final double? amount, maxDiscountAmount, minOrderValue;
}

class GameChallengeStatus {
  const GameChallengeStatus(
      {required this.key,
      required this.gameType,
      required this.title,
      required this.description,
      required this.difficulty,
      required this.questionCount,
      required this.durationSeconds,
      required this.unlockBookings,
      required this.winningScore,
      required this.isActive,
      required this.unlocked,
      required this.progress});
  final String key, gameType, title, description, difficulty;
  final int questionCount, durationSeconds, unlockBookings, winningScore;
  final bool isActive, unlocked;
  final double progress;
}

class MovingGameAttempt {
  const MovingGameAttempt(
      {required this.id,
      required this.gameKey,
      required this.gameType,
      required this.durationMs,
      required this.remainingMs,
      required this.winningScore,
      required this.phases,
      this.cupStartIndex = 0,
      this.cupSwaps = const [],
      required this.questions,
      this.wheelOptions = const [],
      required this.rewardEligible,
      required this.rewardAmount,
      required this.title});
  final String id;
  final String gameKey, gameType;
  final int durationMs;
  final int remainingMs;
  final int winningScore;
  final List<double> phases;
  final int cupStartIndex;
  final List<List<int>> cupSwaps;
  final List<Map<String, dynamic>> questions;
  final List<GameRewardOption> wheelOptions;
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
      this.wheelIndex,
      this.explanation,
      this.currentLane = 1,
      this.dodges = 0,
      this.collisions = 0});
  final bool hit;
  final int score;
  final int hits;
  final int points;
  final int? answerIndex;
  final int? wheelIndex;
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
            verified: data['verified'] == true,
            rewardSystemEnabled: data['rewards_enabled'] != false,
            rewardBudgetAvailable: data['reward_budget_available'] == true,
            rewardOptions: ((data['reward_options'] as List?) ?? const [])
                .whereType<Map>()
                .map((item) {
              final reward = Map<String, dynamic>.from(item);
              return GameRewardOption(
                type: reward['type']?.toString() ?? '',
                title: reward['title']?.toString() ?? '',
                probability: (reward['probability'] as num?)?.toInt() ?? 0,
                amount: (reward['amount'] as num?)?.toDouble(),
                maxDiscountAmount:
                    (reward['max_discount_amount'] as num?)?.toDouble(),
                minOrderValue: (reward['min_order_value'] as num?)?.toDouble(),
                validityDays: (reward['validity_days'] as num?)?.toInt() ?? 0,
              );
            }).toList(),
            availableGames: ((data['available_games'] as List?) ?? const [])
                .whereType<Map>()
                .map((item) {
              final game = Map<String, dynamic>.from(item);
              return GameChallengeStatus(
                key: game['game_key']?.toString() ?? '',
                gameType: game['game_type']?.toString() ?? 'coming_soon',
                title: game['title']?.toString() ?? '',
                description: game['description']?.toString() ?? '',
                difficulty: game['difficulty']?.toString() ?? 'easy',
                questionCount: (game['question_count'] as num?)?.toInt() ?? 5,
                durationSeconds:
                    (game['duration_seconds'] as num?)?.toInt() ?? 30,
                unlockBookings: (game['unlock_bookings'] as num?)?.toInt() ?? 0,
                winningScore: (game['winning_score'] as num?)?.toInt() ?? 300,
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
            gameType: data['game_type']?.toString() ?? 'quiz',
            durationMs: (data['duration_ms'] as num?)?.toInt() ?? 30000,
            remainingMs: (data['remaining_ms'] as num?)?.toInt() ??
                (data['duration_ms'] as num?)?.toInt() ??
                30000,
            winningScore: (data['winning_score'] as num?)?.toInt() ?? 300,
            cupStartIndex:
                ((data['cup_shuffle'] as Map?)?['start_index'] as num?)
                        ?.toInt() ??
                    0,
            cupSwaps:
                ((data['cup_shuffle'] as Map?)?['swaps'] as List? ?? const [])
                    .whereType<List>()
                    .map((swap) =>
                        swap.whereType<num>().map((n) => n.toInt()).toList())
                    .toList(),
            phases: ((data['target_phases'] as List?) ?? const [])
                .whereType<num>()
                .map((e) => e.toDouble())
                .toList(),
            questions: ((data['target_phases'] as List?) ?? const [])
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
            wheelOptions: ((data['wheel_options'] as List?) ?? const [])
                .whereType<Map>()
                .map((item) {
              final reward = Map<String, dynamic>.from(item);
              return GameRewardOption(
                type: reward['type']?.toString() ?? '',
                title: reward['title']?.toString() ?? '',
                probability: (reward['probability'] as num?)?.toInt() ?? 0,
                amount: (reward['amount'] as num?)?.toDouble(),
                maxDiscountAmount:
                    (reward['max_discount_amount'] as num?)?.toDouble(),
                minOrderValue: (reward['min_order_value'] as num?)?.toDouble(),
                validityDays: (reward['validity_days'] as num?)?.toInt() ?? 0,
              );
            }).toList(),
            rewardEligible: data['reward_eligible'] == true,
            rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
            title: data['title']?.toString() ?? 'تحدي كابتن أيوب',
          );
        },
      );

  Future<Either<Failure, MovingGameShot>> shot(
          {required String attemptId,
          required String eventId,
          bool wheelComplete = false,
          int? scenarioIndex,
          int? answerIndex,
          int? lane,
          double? x,
          double? y}) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/shot', isFormData: false, data: {
          'event_uuid': eventId,
          if (wheelComplete) 'wheel_complete': true,
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
            wheelIndex: (data['wheel_index'] as num?)?.toInt(),
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
