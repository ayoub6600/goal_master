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
}
