import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/card/data/repo/card_repo.dart';

part 'add_transaction_state.dart';

class AddTransactionBackEndCubit extends Cubit<AddTransactionState> {
  AddTransactionBackEndCubit(this.repo) : super(AddTransactionInitial());
  final CardRepo repo;

  Future<void> addTransaction(String amount, String status) async {
    emit(AddTransactionLoading());
    final result = await repo.addTransaction(amount, status);
    result.fold((l) => emit(AddTransactionError(l.errMessage)),
        (r) => emit(AddTransactionSuccess(r)));
  }
}
