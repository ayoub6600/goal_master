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

class PromotionalCreditRepo {
  PromotionalCreditRepo(this.api);
  final ApiConsumer api;

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
