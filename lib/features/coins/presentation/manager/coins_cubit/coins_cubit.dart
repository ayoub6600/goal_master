import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/coins/data/model/coin_model.dart';
import 'package:goal_master/features/coins/data/repo/coins_repo.dart';

part 'coins_state.dart';

class CoinsCubit extends Cubit<CoinsState> {
  CoinsCubit(this.coinsRepo) : super(const CoinsState());

  final CoinsRepo coinsRepo;

  Future<void> getBalance() async {
    emit(state.copyWith(loadingBalance: true, clearError: true));
    final result = await coinsRepo.getBalance();
    result.fold(
      (failure) => emit(state.copyWith(
        loadingBalance: false,
        error: failure.errMessage,
      )),
      (balance) {
        final previous = state.balance?.coinsBalance;
        final earned = (previous != null && balance.coinsBalance > previous)
            ? balance.coinsBalance - previous
            : null;
        emit(state.copyWith(
          loadingBalance: false,
          balance: balance,
          justEarnedCoins: earned,
        ));
      },
    );
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (state.loadingHistory) return;
    final nextPage = refresh ? 1 : state.historyPage + 1;
    emit(state.copyWith(loadingHistory: true));
    final result = await coinsRepo.getHistory(page: nextPage);
    result.fold(
      (failure) => emit(state.copyWith(loadingHistory: false)),
      (page) => emit(state.copyWith(
        loadingHistory: false,
        history: refresh ? page.transactions : [...state.history, ...page.transactions],
        historyPage: page.currentPage,
        hasMoreHistory: page.hasMore,
      )),
    );
  }

  Future<bool> redeem(int coins) async {
    emit(state.copyWith(redeeming: true, clearRedeemError: true));
    final result = await coinsRepo.redeem(coins);
    return result.fold(
      (failure) {
        emit(state.copyWith(redeeming: false, redeemError: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(redeeming: false));
        getBalance();
        loadHistory(refresh: true);
        return true;
      },
    );
  }

  void clearJustEarned() {
    emit(state.copyWith(clearJustEarned: true));
  }

  /// Asks the backend what may be spent on this specific booking. Called when
  /// the checkout screen opens — including after the app was backgrounded and
  /// resumed, so a stale offer is never shown.
  Future<void> loadCheckoutQuote({
    required int serviceId,
    required int employeeId,
  }) async {
    final result = await coinsRepo.quoteForBooking(
      serviceId: serviceId,
      employeeId: employeeId,
    );
    result.fold(
      // A failed quote just means no coins option is offered — it must never
      // block the customer from booking.
      (_) => emit(state.copyWith(clearCheckout: true)),
      (quote) => emit(state.copyWith(
        checkoutQuote: quote,
        // Default to spending the most that's allowed, which is what a
        // customer toggling "use my coins" almost always intends.
        selectedCheckoutCoins: quote.maxRedeemableCoins,
        useCoinsAtCheckout: false,
      )),
    );
  }

  void setUseCoinsAtCheckout(bool value) {
    emit(state.copyWith(useCoinsAtCheckout: value));
  }

  void setCheckoutCoins(int coins) {
    final quote = state.checkoutQuote;
    if (quote == null) return;
    emit(state.copyWith(
      selectedCheckoutCoins: coins.clamp(0, quote.maxRedeemableCoins),
    ));
  }

  /// Clears the checkout selection once a booking is submitted, so the next
  /// checkout starts from a fresh server quote rather than a stale one.
  void clearCheckout() {
    emit(state.copyWith(clearCheckout: true));
  }
}
