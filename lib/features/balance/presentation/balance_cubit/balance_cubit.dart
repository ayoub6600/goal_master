import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo.dart';

part 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this.balanceRep) : super(BalanceInitial());
  final BalanceRepo balanceRep;

  Future<void> getBalance() async {
    emit(BalanceLoading());
    final result = await balanceRep.getBalance();
    result.fold(
      (l) => emit(BalanceError(l.errMessage)),
      (r) => emit(BalanceLoaded(r)),
    );
  }
}
