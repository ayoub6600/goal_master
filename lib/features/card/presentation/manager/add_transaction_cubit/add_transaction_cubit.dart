import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/card/data/model/topup_checkout.dart';
import 'package:goal_master/features/card/data/repo/card_repo.dart';

part 'add_transaction_state.dart';

/// A card top-up from start to finish. The server opens it (reference,
/// amount, signature) and decides whether it was paid; this app never
/// tells the server how much to credit.
class AddTransactionBackEndCubit extends Cubit<AddTransactionState> {
  AddTransactionBackEndCubit(this.repo) : super(AddTransactionInitial());
  final CardRepo repo;

  Future<void> start(String amount) async {
    emit(AddTransactionLoading());
    final result = await repo.startTopUp(amount);
    result.fold((l) => emit(AddTransactionError(l.errMessage)),
        (checkout) => emit(AddTransactionReady(checkout)));
  }

  Future<void> confirm(String reference) async {
    emit(AddTransactionLoading());
    final result = await repo.confirmTopUp(reference);
    result.fold(
      (l) => emit(AddTransactionError(l.errMessage)),
      (r) => emit(r.credited
          ? AddTransactionSuccess(r.message)
          : AddTransactionPending(r.message)),
    );
  }
}
