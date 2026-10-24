import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/promotional_credit/data/promotional_credit_repo.dart';

class PromotionalCreditState extends Equatable {
  const PromotionalCreditState({
    this.quote,
    this.balance,
    this.useAtCheckout = false,
  });

  final PromotionalCreditQuote? quote;
  final double? balance;
  final bool useAtCheckout;

  double get amountToUse => useAtCheckout ? (quote?.maxRedeemable ?? 0) : 0;

  PromotionalCreditState copyWith({
    PromotionalCreditQuote? quote,
    double? balance,
    bool? useAtCheckout,
    bool clearQuote = false,
  }) =>
      PromotionalCreditState(
        quote: clearQuote ? null : (quote ?? this.quote),
        balance: balance ?? this.balance,
        useAtCheckout:
            clearQuote ? false : (useAtCheckout ?? this.useAtCheckout),
      );

  @override
  List<Object?> get props => [quote, balance, useAtCheckout];
}

class PromotionalCreditCubit extends Cubit<PromotionalCreditState> {
  PromotionalCreditCubit(this.repo) : super(const PromotionalCreditState());
  final PromotionalCreditRepo repo;

  Future<void> loadBalance() async {
    final result = await repo.getBalance();
    result.fold(
      (_) {},
      (balance) => emit(state.copyWith(balance: balance)),
    );
  }

  Future<void> loadQuote(double bookingAmount) async {
    final result = await repo.quote(bookingAmount);
    result.fold(
      (_) => emit(state.copyWith(clearQuote: true)),
      (quote) => emit(state.copyWith(quote: quote, useAtCheckout: false)),
    );
  }

  void setUseAtCheckout(bool value) =>
      emit(state.copyWith(useAtCheckout: value));

  void clearCheckout() => emit(state.copyWith(clearQuote: true));
}
