import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/errors/failure.dart';

int _int(Object? v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;
double _double(Object? v) => (v as num?)?.toDouble() ?? 0;

class PenaltyTier {
  const PenaltyTier({
    required this.challengeId,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.kicksTotal,
    required this.goalsToWin,
    required this.unlockBookings,
    required this.unlocked,
    required this.progress,
  });

  factory PenaltyTier.fromJson(Map<String, dynamic> j) => PenaltyTier(
        challengeId: _int(j['challenge_id']),
        difficulty: j['difficulty']?.toString() ?? 'easy',
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        kicksTotal: _int(j['kicks_total'], 5),
        goalsToWin: _int(j['goals_to_win'], 3),
        unlockBookings: _int(j['unlock_bookings']),
        unlocked: j['unlocked'] == true,
        progress: _double(j['progress']),
      );

  final int challengeId, kicksTotal, goalsToWin, unlockBookings;
  final String difficulty, title, description;
  final bool unlocked;
  final double progress;
}

class PenaltyStatus {
  const PenaltyStatus({
    required this.enabled,
    required this.verified,
    required this.cooldownSeconds,
    required this.tiers,
  });

  final bool enabled, verified;
  final int cooldownSeconds;
  final List<PenaltyTier> tiers;
}

class PenaltyAttempt {
  const PenaltyAttempt({
    required this.id,
    required this.kicksTotal,
    required this.kicksTaken,
    required this.goalsScored,
    required this.goalsToWin,
    required this.difficulty,
    required this.title,
    required this.rewardEligible,
  });

  final String id, difficulty, title;
  final int kicksTotal, kicksTaken, goalsScored, goalsToWin;
  final bool rewardEligible;
}

/// What the server decided for one kick: `goal`, `save`, `post` or `miss`.
class PenaltyKickResult {
  const PenaltyKickResult({
    required this.outcome,
    required this.scored,
    required this.keeperZone,
    required this.kicksTaken,
    required this.goalsScored,
  });

  final String outcome;
  final bool scored;
  final int keeperZone, kicksTaken, goalsScored;
}

class PenaltyResult {
  const PenaltyResult({
    required this.won,
    required this.goalsScored,
    required this.rewardEligible,
    this.rewardType,
    this.rewardTitle,
    this.rewardReference,
    this.rewardAmount = 0,
    this.rewardDetails = const {},
  });

  final bool won, rewardEligible;
  final int goalsScored;
  final String? rewardType, rewardTitle, rewardReference;
  final double rewardAmount;
  final Map<String, dynamic> rewardDetails;

  bool get hasPrize =>
      won && rewardType != null && rewardType != 'no_prize';
}

class PenaltyShootoutRepo {
  PenaltyShootoutRepo(this.api);
  final ApiConsumer api;
  static const _root = 'user/games/penalty';

  Future<Either<Failure, PenaltyStatus>> status() => api.handleRequest(
        () => api.get('$_root/'),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return PenaltyStatus(
            enabled: data['enabled'] == true,
            verified: data['verified'] == true,
            cooldownSeconds: _int(data['cooldown_seconds']),
            tiers: ((data['difficulties'] as List?) ?? const [])
                .whereType<Map>()
                .map((e) => PenaltyTier.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        },
      );

  Future<Either<Failure, PenaltyAttempt>> start(int challengeId) =>
      api.handleRequest(
        () => api.post('$_root/start',
            isFormData: false, data: {'challenge_id': challengeId}),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return PenaltyAttempt(
            id: data['attempt_id']?.toString() ?? '',
            kicksTotal: _int(data['kicks_total'], 5),
            kicksTaken: _int(data['kicks_taken']),
            goalsScored: _int(data['goals_scored']),
            goalsToWin: _int(data['goals_to_win'], 3),
            difficulty: data['difficulty']?.toString() ?? 'easy',
            title: data['title']?.toString() ?? 'ركلات الترجيح',
            rewardEligible: data['reward_eligible'] == true,
          );
        },
      );

  Future<Either<Failure, PenaltyKickResult>> kick({
    required String attemptId,
    required String eventId,
    required double aimX,
    required double aimY,
  }) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/kick', isFormData: false, data: {
          'event_uuid': eventId,
          'aim_x': double.parse(aimX.toStringAsFixed(4)),
          'aim_y': double.parse(aimY.toStringAsFixed(4)),
        }),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return PenaltyKickResult(
            outcome: data['outcome']?.toString() ?? 'miss',
            scored: data['scored'] == true,
            keeperZone: _int(data['keeper_zone'], 4),
            kicksTaken: _int(data['kicks_taken']),
            goalsScored: _int(data['goals_scored']),
          );
        },
      );

  Future<Either<Failure, PenaltyResult>> complete(String attemptId) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/complete', isFormData: false),
        (response) {
          final data = Map<String, dynamic>.from(response['data'] ?? {});
          return PenaltyResult(
            won: data['won'] == true,
            goalsScored: _int(data['goals_scored']),
            rewardEligible: data['reward_eligible'] == true,
            rewardType: data['reward_type']?.toString(),
            rewardTitle: data['reward_title']?.toString(),
            rewardReference: data['reward_reference']?.toString(),
            rewardAmount: _double(data['reward_amount']),
            rewardDetails: data['reward_details'] is Map
                ? Map<String, dynamic>.from(data['reward_details'])
                : const {},
          );
        },
      );
}
