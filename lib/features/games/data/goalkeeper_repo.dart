import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/games/data/penalty_shootout_repo.dart';

int _int(Object? v, [int fallback = 0]) => (v as num?)?.toInt() ?? fallback;
double _double(Object? v) => (v as num?)?.toDouble() ?? 0;

class GoalkeeperTier {
  const GoalkeeperTier({
    required this.challengeId,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.shotsTotal,
    required this.savesToWin,
    required this.shooterSkill,
    required this.unlockBookings,
    required this.unlocked,
    required this.progress,
  });

  factory GoalkeeperTier.fromJson(Map<String, dynamic> j) => GoalkeeperTier(
        challengeId: _int(j['challenge_id']),
        difficulty: j['difficulty']?.toString() ?? 'easy',
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        shotsTotal: _int(j['shots_total'], 5),
        savesToWin: _int(j['saves_to_win'], 3),
        shooterSkill: _int(j['shooter_skill'], 50),
        unlockBookings: _int(j['unlock_bookings']),
        unlocked: j['unlocked'] == true,
        progress: _double(j['progress']),
      );

  final int challengeId, shotsTotal, savesToWin, shooterSkill, unlockBookings;
  final String difficulty, title, description;
  final bool unlocked;
  final double progress;
}

class GoalkeeperStatus {
  const GoalkeeperStatus({
    required this.enabled,
    required this.verified,
    required this.cooldownSeconds,
    required this.bestSaves,
    required this.tiers,
  });

  final bool enabled, verified;
  final int cooldownSeconds, bestSaves;
  final List<GoalkeeperTier> tiers;
}

class GoalkeeperRound {
  const GoalkeeperRound({
    required this.id,
    required this.shotsTotal,
    required this.savesToWin,
    required this.shooterSkill,
    required this.difficulty,
    required this.title,
    required this.rewardEligible,
    required this.runupMs,
  });

  final String id, difficulty, title;
  final int shotsTotal, savesToWin, shooterSkill, runupMs;
  final bool rewardEligible;
}

/// One shot as the server picked it: where it crosses the line (metres),
/// how long it flies, and how much it bends on the way.
class GoalkeeperShot {
  const GoalkeeperShot({
    required this.number,
    required this.x,
    required this.y,
    required this.flightMs,
    required this.curl,
    required this.runupMs,
  });

  factory GoalkeeperShot.fromJson(Map<String, dynamic> j) => GoalkeeperShot(
        number: _int(j['shot_number'], 1),
        x: _double(j['target_x']),
        y: _double(j['target_y']),
        flightMs: _int(j['flight_ms'], 900),
        curl: _double(j['curl']),
        runupMs: _int(j['runup_ms'], 1100),
      );

  final int number, flightMs, runupMs;
  final double x, y, curl;
}

class GoalkeeperVerdict {
  const GoalkeeperVerdict({
    required this.saved,
    required this.gloveX,
    required this.gloveY,
    required this.saves,
    required this.shotsTaken,
    required this.decided,
  });

  final bool saved, decided;
  final double gloveX, gloveY;
  final int saves, shotsTaken;
}

class GoalkeeperResult {
  const GoalkeeperResult({required this.saves, required this.savesToWin, required this.newBest, required this.prize});
  final int saves, savesToWin;
  final bool newBest;

  /// The verdict in the shape the shared result panel renders.
  final PenaltyResult prize;
}

class GoalkeeperRepo {
  GoalkeeperRepo(this.api);
  final ApiConsumer api;
  static const _root = 'user/games/goalkeeper';

  Future<Either<Failure, GoalkeeperStatus>> status() => api.handleRequest(
        () => api.get('$_root/'),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          return GoalkeeperStatus(
            enabled: d['enabled'] == true,
            verified: d['verified'] == true,
            cooldownSeconds: _int(d['cooldown_seconds']),
            bestSaves: _int(d['best_saves']),
            tiers: ((d['difficulties'] as List?) ?? const [])
                .whereType<Map>()
                .map((e) => GoalkeeperTier.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
          );
        },
      );

  Future<Either<Failure, GoalkeeperRound>> start(int challengeId) => api.handleRequest(
        () => api.post('$_root/start', isFormData: false, data: {'challenge_id': challengeId}),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          return GoalkeeperRound(
            id: d['attempt_id']?.toString() ?? '',
            shotsTotal: _int(d['shots_total'], 5),
            savesToWin: _int(d['saves_to_win'], 3),
            shooterSkill: _int(d['shooter_skill'], 50),
            difficulty: d['difficulty']?.toString() ?? 'easy',
            title: d['title']?.toString() ?? 'كن الحارس',
            rewardEligible: d['reward_eligible'] == true,
            runupMs: _int(d['runup_ms'], 1100),
          );
        },
      );

  /// Asks the server for the next shot. Safe to repeat: an open shot comes
  /// back unchanged.
  Future<Either<Failure, GoalkeeperShot>> shot(String attemptId) => api.handleRequest(
        () => api.post('$_root/$attemptId/shot', isFormData: false, data: const {}),
        (response) => GoalkeeperShot.fromJson(Map<String, dynamic>.from(response['data'] ?? {})),
      );

  /// Reports the dive ([diveMs] after the strike, toward [x], [y] in goal
  /// metres), or no dive at all. Safe to retry.
  Future<Either<Failure, GoalkeeperVerdict>> dive(String attemptId, int shotNumber,
          {int? diveMs, double? x, double? y}) =>
      api.handleRequest(
        () => api.post('$_root/$attemptId/dive', isFormData: false, data: {
          'shot_number': shotNumber,
          if (diveMs != null) ...{
            'dive_ms': diveMs,
            'x': double.parse(x!.toStringAsFixed(2)),
            'y': double.parse(y!.toStringAsFixed(2)),
          },
        }),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          return GoalkeeperVerdict(
            saved: d['saved'] == true,
            gloveX: _double(d['glove_x']),
            gloveY: _double(d['glove_y']),
            saves: _int(d['saves']),
            shotsTaken: _int(d['shots_taken']),
            decided: d['decided'] == true,
          );
        },
      );

  Future<Either<Failure, GoalkeeperResult>> complete(String attemptId) => api.handleRequest(
        () => api.post('$_root/$attemptId/complete', isFormData: false, data: const {}),
        (response) {
          final d = Map<String, dynamic>.from(response['data'] ?? {});
          final saves = _int(d['saves']);
          return GoalkeeperResult(
            saves: saves,
            savesToWin: _int(d['saves_to_win'], 3),
            newBest: d['new_best'] == true,
            prize: PenaltyResult(
              won: d['won'] == true,
              goalsScored: saves,
              rewardEligible: d['reward_eligible'] == true,
              rewardType: d['reward_type']?.toString(),
              rewardTitle: d['reward_title']?.toString(),
              rewardReference: d['reward_reference']?.toString(),
              rewardAmount: _double(d['reward_amount']),
              rewardDetails: d['reward_details'] is Map ? Map<String, dynamic>.from(d['reward_details']) : const {},
            ),
          );
        },
      );
}
