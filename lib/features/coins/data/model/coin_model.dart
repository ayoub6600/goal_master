int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  return int.tryParse('$value') ?? fallback;
}

class CoinBalance {
  final int coinsBalance;
  final int pendingCoins;
  final int lifetimeEarned;
  final int lifetimeSpent;
  final double moneyValue;
  final int minRedeemCoins;
  final int redeemRate;
  final bool isActive;

  CoinBalance({
    required this.coinsBalance,
    this.pendingCoins = 0,
    this.lifetimeEarned = 0,
    this.lifetimeSpent = 0,
    required this.moneyValue,
    required this.minRedeemCoins,
    required this.redeemRate,
    required this.isActive,
  });

  factory CoinBalance.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    return CoinBalance(
      coinsBalance: _asInt(data['coins_balance']),
      pendingCoins: _asInt(data['pending_coins']),
      lifetimeEarned: _asInt(data['lifetime_earned']),
      lifetimeSpent: _asInt(data['lifetime_spent']),
      moneyValue: (data['money_value'] as num?)?.toDouble() ?? 0,
      minRedeemCoins: _asInt(data['min_redeem_coins']),
      redeemRate: _asInt(data['redeem_rate'], 1),
      isActive: data['is_active'] == true,
    );
  }
}

/// Server-computed answer to "how many coins can this customer put toward a
/// booking of X?" — the checkout screen renders this and never derives the
/// cap or the discount itself.
class CoinRedeemQuote {
  final int coinsBalance;
  final int maxRedeemableCoins;
  final double maxDiscountValue;
  final int minRedeemCoins;
  final int redeemRate;
  final bool isActive;

  CoinRedeemQuote({
    required this.coinsBalance,
    required this.maxRedeemableCoins,
    required this.maxDiscountValue,
    required this.minRedeemCoins,
    required this.redeemRate,
    required this.isActive,
  });

  bool get canRedeem => isActive && maxRedeemableCoins >= minRedeemCoins;

  factory CoinRedeemQuote.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    return CoinRedeemQuote(
      coinsBalance: _asInt(data['coins_balance']),
      maxRedeemableCoins: _asInt(data['max_redeemable_coins']),
      maxDiscountValue: (data['max_discount_value'] as num?)?.toDouble() ?? 0,
      minRedeemCoins: _asInt(data['min_redeem_coins']),
      redeemRate: _asInt(data['redeem_rate'], 1),
      isActive: data['is_active'] == true,
    );
  }
}

/// What the customer may spend on one specific booking. Every figure here
/// is computed by the backend (including the booking price itself, which the
/// checkout screen otherwise has no way to know) — the app only renders it.
class CoinCheckoutQuote {
  final double bookingAmount;
  final int coinsBalance;
  final int maxRedeemableCoins;
  final double maxDiscountValue;
  final int minRedeemCoins;
  final int redeemRate;
  final bool isActive;

  CoinCheckoutQuote({
    required this.bookingAmount,
    required this.coinsBalance,
    required this.maxRedeemableCoins,
    required this.maxDiscountValue,
    required this.minRedeemCoins,
    required this.redeemRate,
    required this.isActive,
  });

  /// Whether it's even worth showing the control — an inactive module or a
  /// balance under the minimum means there is nothing to offer.
  bool get canRedeem => isActive && maxRedeemableCoins >= minRedeemCoins;

  double discountFor(int coins) =>
      redeemRate > 0 ? (coins / redeemRate) : 0;

  factory CoinCheckoutQuote.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});
    int asInt(String key) => data[key] is int
        ? data[key]
        : int.tryParse('${data[key]}') ?? 0;

    return CoinCheckoutQuote(
      bookingAmount: (data['booking_amount'] as num?)?.toDouble() ?? 0,
      coinsBalance: asInt('coins_balance'),
      maxRedeemableCoins: asInt('max_redeemable_coins'),
      maxDiscountValue: (data['max_discount_value'] as num?)?.toDouble() ?? 0,
      minRedeemCoins: asInt('min_redeem_coins'),
      redeemRate: asInt('redeem_rate') == 0 ? 1 : asInt('redeem_rate'),
      isActive: data['is_active'] == true,
    );
  }
}

class CoinHistoryPage {
  final List<CoinTransaction> transactions;
  final int currentPage;
  final int lastPage;

  CoinHistoryPage({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory CoinHistoryPage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((e) => CoinTransaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return CoinHistoryPage(
      transactions: list,
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse('${json['current_page']}') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse('${json['last_page']}') ?? 1,
    );
  }
}

class CoinTransaction {
  final int id;
  final int coinType; // 1 = credit (earned/adjusted in), 0 = debit (redeemed)
  final int amount;
  final String type; // booking_reward | redeem | refund | admin_adjustment ...
  final String status; // pending | available | cancelled | expired
  final String? description;
  final int? bookingId;
  final String? expiresAt;
  final String? createdAt;

  CoinTransaction({
    required this.id,
    required this.coinType,
    required this.amount,
    required this.type,
    this.status = 'available',
    this.description,
    this.bookingId,
    this.expiresAt,
    this.createdAt,
  });

  bool get isCredit => coinType == 1;
  bool get isPending => status == 'pending';

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: _asInt(json['id']),
      coinType: _asInt(json['coin_type']),
      amount: _asInt(json['amount']),
      type: json['type']?.toString() ?? 'booking_reward',
      status: json['status']?.toString() ?? 'available',
      description: json['description']?.toString(),
      bookingId: json['booking_id'] == null ? null : _asInt(json['booking_id']),
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
