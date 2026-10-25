import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';

class PromotionalCreditQuote {
  const PromotionalCreditQuote({
    required this.balance,
    required this.maxRedeemable,
    required this.bookingAmount,
  });

  final double balance;
  final double maxRedeemable;
  final double bookingAmount;

  bool get canRedeem => maxRedeemable > 0;
}

class PromotionalCreditHistoryEntry {
  const PromotionalCreditHistoryEntry({
    required this.amount,
    required this.entryType,
    required this.description,
    required this.createdAt,
  });
  final double amount;
  final String entryType;
  final String description;
  final String createdAt;
}

class VenueMarketingOffer {
  const VenueMarketingOffer({
    required this.id,
    required this.name,
    required this.discount,
    required this.fundedBy,
    this.discountType,
    this.discountValue,
  });
  final int id;
  final String name;
  final double discount;
  final String fundedBy;
  final String? discountType;
  final double? discountValue;
}

class FootballChallengeStatus {
  const FootballChallengeStatus({
    required this.enabled,
    required this.verified,
    required this.canPlay,
    required this.played,
    required this.rewardAmount,
    required this.rewardPlaysRemaining,
  });
  final bool enabled;
  final bool verified;
  final bool canPlay;
  final bool played;
  final double rewardAmount;
  final int rewardPlaysRemaining;
}

class FootballChallengeAttempt {
  const FootballChallengeAttempt({
    required this.id,
    required this.rewardEligible,
    required this.rewardAmount,
    this.keeperTell = 'center',
  });
  final String id;
  final bool rewardEligible;
  final double rewardAmount;
  final String keeperTell;
}

class FootballChallengeResult {
  const FootballChallengeResult({
    required this.succeeded,
    required this.rewardAmount,
  });
  final bool succeeded;
  final double rewardAmount;
}

class PromotionalCreditRepo {
  PromotionalCreditRepo(this.api);
  final ApiConsumer api;

  Future<Either<Failure, FootballChallengeStatus>> getFootballChallenge() {
    return api.handleRequest(
      () => api.get(EndPoints.footballChallenge),
      (response) {
        final data = Map<String, dynamic>.from(response['data'] ?? {});
        return FootballChallengeStatus(
          enabled: data['enabled'] == true,
          verified: data['verified'] == true,
          canPlay: data['can_play'] == true,
          played: data['played'] == true,
          rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
          rewardPlaysRemaining:
              (data['reward_plays_remaining'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }

  Future<Either<Failure, FootballChallengeAttempt>> startFootballChallenge() {
    return api.handleRequest(
      () => api.post(EndPoints.footballChallengeStart, isFormData: false),
      (response) {
        final data = Map<String, dynamic>.from(response['data'] ?? {});
        return FootballChallengeAttempt(
          id: data['attempt_id']?.toString() ?? '',
          rewardEligible: data['reward_eligible'] == true,
          rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
          keeperTell: data['keeper_tell']?.toString() ?? 'center',
        );
      },
    );
  }

  Future<Either<Failure, FootballChallengeResult>> submitFootballShot({
    required String attemptId,
    required double aimX,
    required double aimY,
    required double power,
  }) {
    return api.handleRequest(
      () => api.post(
        EndPoints.footballChallengeShoot(attemptId),
        isFormData: false,
        data: {'aim_x': aimX, 'aim_y': aimY, 'power': power},
      ),
      (response) {
        final data = Map<String, dynamic>.from(response['data'] ?? {});
        return FootballChallengeResult(
          succeeded: data['succeeded'] == true,
          rewardAmount: (data['reward_amount'] as num?)?.toDouble() ?? 0,
        );
      },
    );
  }

  Future<Either<Failure, List<VenueMarketingOffer>>> getVenueOffers({
    required int branchId,
    required int serviceId,
    required double amount,
    required String bookingAt,
  }) {
    return api.handleRequest(
      () => api.post(
        EndPoints.venueMarketingOffers,
        isFormData: false,
        data: {
          'branch_id': branchId,
          'service_id': serviceId,
          'amount': amount,
          'booking_at': bookingAt,
        },
      ),
      (response) =>
          ((response['data']?['offers'] as List?) ?? const []).map((item) {
        final data = Map<String, dynamic>.from(item as Map);
        return VenueMarketingOffer(
          id: int.tryParse('${data['id']}') ?? 0,
          name: data['name']?.toString() ?? '',
          discount: (data['discount'] as num?)?.toDouble() ?? 0,
          fundedBy: data['funded_by']?.toString() ?? 'venue',
          discountType: data['discount_type']?.toString(),
          discountValue: (data['discount_value'] as num?)?.toDouble(),
        );
      }).toList(),
    );
  }

  Future<Either<Failure, double>> getBalance() {
    return api.handleRequest(
      () => api.get(EndPoints.promotionalWallet),
      (response) {
        final data = Map<String, dynamic>.from(response['data'] ?? {});
        return (data['promotional_balance'] as num?)?.toDouble() ?? 0;
      },
    );
  }

  Future<Either<Failure, List<PromotionalCreditHistoryEntry>>> getHistory() {
    return api.handleRequest(
      () => api.get(EndPoints.promotionalWallet),
      (response) => ((response['data']?['transactions'] as List?) ?? const [])
          .map((item) {
        final data = Map<String, dynamic>.from(item as Map);
        return PromotionalCreditHistoryEntry(
          amount: (data['amount'] as num?)?.toDouble() ?? 0,
          entryType: data['entry_type']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
          createdAt: data['created_at']?.toString() ?? '',
        );
      }).toList(),
    );
  }

  Future<Either<Failure, PromotionalCreditQuote>> quote(double amount) {
    return api.handleRequest(
      () => api.post(
        EndPoints.promotionalWalletQuote,
        isFormData: false,
        data: {'amount': amount},
      ),
      (response) {
        final data = Map<String, dynamic>.from(response['data'] ?? {});
        double value(String key) => (data[key] as num?)?.toDouble() ?? 0;
        return PromotionalCreditQuote(
          balance: value('promotional_balance'),
          maxRedeemable: value('max_redeemable'),
          bookingAmount: value('booking_amount'),
        );
      },
    );
  }
}
