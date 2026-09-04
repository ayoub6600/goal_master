part of 'coins_cubit.dart';

class CoinsState extends Equatable {
  final CoinBalance? balance;
  final List<CoinTransaction> history;
  final bool loadingBalance;
  final bool loadingHistory;
  final bool redeeming;
  final bool hasMoreHistory;
  final int historyPage;
  final String? error;
  final String? redeemError;

  /// Set right after a getBalance() call notices the coins balance went up
  /// compared to what was already loaded — the celebratory popup watches
  /// this, shows itself, then calls clearJustEarned() to consume it.
  final int? justEarnedCoins;

  /// Checkout-scoped: what the backend says may be spent on the booking
  /// currently being confirmed, and how much of it the customer opted into.
  final CoinCheckoutQuote? checkoutQuote;
  final bool useCoinsAtCheckout;
  final int selectedCheckoutCoins;

  const CoinsState({
    this.balance,
    this.history = const [],
    this.loadingBalance = false,
    this.loadingHistory = false,
    this.redeeming = false,
    this.hasMoreHistory = false,
    this.historyPage = 0,
    this.error,
    this.redeemError,
    this.justEarnedCoins,
    this.checkoutQuote,
    this.useCoinsAtCheckout = false,
    this.selectedCheckoutCoins = 0,
  });

  /// Coins actually sent with the booking request — zero unless the customer
  /// switched the option on and the quote still permits it.
  int get coinsToRedeem {
    final quote = checkoutQuote;
    if (!useCoinsAtCheckout || quote == null || !quote.canRedeem) return 0;
    if (selectedCheckoutCoins < quote.minRedeemCoins) return 0;
    return selectedCheckoutCoins.clamp(0, quote.maxRedeemableCoins);
  }

  double get checkoutDiscount =>
      checkoutQuote?.discountFor(coinsToRedeem) ?? 0;

  CoinsState copyWith({
    CoinBalance? balance,
    List<CoinTransaction>? history,
    bool? loadingBalance,
    bool? loadingHistory,
    bool? redeeming,
    bool? hasMoreHistory,
    int? historyPage,
    String? error,
    String? redeemError,
    int? justEarnedCoins,
    CoinCheckoutQuote? checkoutQuote,
    bool? useCoinsAtCheckout,
    int? selectedCheckoutCoins,
    bool clearJustEarned = false,
    bool clearError = false,
    bool clearRedeemError = false,
    bool clearCheckout = false,
  }) {
    return CoinsState(
      balance: balance ?? this.balance,
      history: history ?? this.history,
      loadingBalance: loadingBalance ?? this.loadingBalance,
      loadingHistory: loadingHistory ?? this.loadingHistory,
      redeeming: redeeming ?? this.redeeming,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      historyPage: historyPage ?? this.historyPage,
      error: clearError ? null : (error ?? this.error),
      redeemError: clearRedeemError ? null : (redeemError ?? this.redeemError),
      justEarnedCoins:
          clearJustEarned ? null : (justEarnedCoins ?? this.justEarnedCoins),
      checkoutQuote:
          clearCheckout ? null : (checkoutQuote ?? this.checkoutQuote),
      useCoinsAtCheckout: clearCheckout
          ? false
          : (useCoinsAtCheckout ?? this.useCoinsAtCheckout),
      selectedCheckoutCoins: clearCheckout
          ? 0
          : (selectedCheckoutCoins ?? this.selectedCheckoutCoins),
    );
  }

  @override
  List<Object?> get props => [
        balance,
        history,
        loadingBalance,
        loadingHistory,
        redeeming,
        hasMoreHistory,
        historyPage,
        error,
        redeemError,
        justEarnedCoins,
        checkoutQuote,
        useCoinsAtCheckout,
        selectedCheckoutCoins,
      ];
}
