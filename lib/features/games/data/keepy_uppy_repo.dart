import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';
import 'package:goal_master/features/games/presentation/keepy/keepy_sim.dart';

int _int(Object? v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;
double _double(Object? v) => (v as num?)?.toDouble() ?? 0;

class KeepyTier {
  const KeepyTier({
    required this.challengeId,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.target,
    required this.ballDifficulty,
    required this.unlockBookings,
    required this.unlocked,
    required this.progress,
  });

  factory KeepyTier.fromJson(Map<String, dynamic> j) => KeepyTier(
        challengeId: _int(j['challenge_id']),
        difficulty: j['difficulty']?.toString() ?? 'easy',
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        target: _int(j['target'], 10),
        ballDifficulty: _int(j['ball_difficulty'], 40),
        unlockBookings: _int(j['unlock_bookings']),
        unlocked: j['unlocked'] == true,
        progress: _double(j['progress']),
      );

  final int challengeId, target, ballDifficulty, unlockBookings;
  final String difficulty, title, description;
  final bool unlocked;
  final double progress;
}

class KeepyStatus {
  const KeepyStatus({
    required this.enabled,
    required this.verified,
    required this.cooldownSeconds,
    required this.bestTouches,
    required this.tiers,
  });

  final bool enabled, verified;
  final int cooldownSeconds, bestTouches;
  final List<KeepyTier> tiers;
}

class KeepyRound {
  const KeepyRound({
    required this.id,
    required this.seed,
    required this.physics,
    required this.difficulty,
    required this.title,
    required this.rewardEligible,
  });

  final String id, difficulty, title;
  final int seed;
  final KeepyPhysics physics;
  final bool rewardEligible;
}

class KeepyResult {
  const KeepyResult({
    required this.touches,
    required this.target,
    required this.rejected,
    required this.newBest,
    required this.prize,
  });

  final int touches, target;
  final bool rejected, newBest;

  /// The verdict in the shape the shared result panel renders.
  final PenaltyResult prize;
}

class KeepyUppyRepo {
  KeepyUppyRepo(this.api);
  final ApiConsumer api;
  static const _root = 'user/games/keepy-uppy';

  Future<Either<Failure, KeepyStatus>> status() => api.handleRequest(
        () => api.get('$_root/'),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          return KeepyStatus(
            enabled: d['enabled'] == true,
            verified: d['verified'] == true,
            cooldownSeconds: _int(d['cooldown_seconds']),
            bestTouches: _int(d['best_touches']),
            tiers: ((d['difficulties'] as List?) ?? const [])
                .whereType<Map>()
                .map((e) => KeepyTier.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        },
      );

  Future<Either<Failure, KeepyRound>> start(int challengeId) =>
      api.handleRequest(
        () => api.post('$_root/start',
            isFormData: false, data: {'challenge_id': challengeId}),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          return KeepyRound(
            id: d['attempt_id']?.toString() ?? '',
            seed: _int(d['seed']),
            physics: KeepyPhysics.fromJson(
                Map<String, dynamic>.from(d['physics'] as Map)),
            difficulty: d['difficulty']?.toString() ?? 'easy',
            title: d['title']?.toString() ?? 'تنطيط الكرة',
            rewardEligible: d['reward_eligible'] == true,
          );
        },
      );

  /// Sends every tap; the server replays them and its count is the result.
  /// Safe to retry: a finished round returns its original verdict.
  Future<Either<Failure, KeepyResult>> finish(
          String attemptId, List<KeepyTap> taps) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/finish', isFormData: false, data: {
          'taps': [for (final t in taps) t.toJson()]
        }),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          final touches = _int(d['touches']);
          return KeepyResult(
            touches: touches,
            target: _int(d['target']),
            rejected: d['rejected'] == true,
            newBest: d['new_best'] == true,
            prize: PenaltyResult(
              won: d['won'] == true,
              goalsScored: touches,
              rewardEligible: d['reward_eligible'] == true,
              rewardType: d['reward_type']?.toString(),
              rewardTitle: d['reward_title']?.toString(),
              rewardReference: d['reward_reference']?.toString(),
              rewardAmount: _double(d['reward_amount']),
              rewardDetails: d['reward_details'] is Map
                  ? Map<String, dynamic>.from(d['reward_details'])
                  : const {},
            ),
          );
        },
      );
}
