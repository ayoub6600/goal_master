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
  });

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
    bool clearJustEarned = false,
    bool clearError = false,
    bool clearRedeemError = false,
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
      ];
}
