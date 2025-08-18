import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:goal_master/features/balance/data/repo/balance_repo.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final BalanceRepo balanceRep;
  late final PagingController<int, Transaction> pagingController;

  TransactionCubit(this.balanceRep) : super(TransactionInitial()) {
    pagingController = PagingController<int, Transaction>(firstPageKey: 1);
    pagingController.addPageRequestListener((pageKey) {
      _fetchTransactions(pageKey);
    });

    emit(TransactionSuccess(pagingController: pagingController));
  }

  Future<void> _fetchTransactions(int pageKey) async {
    try {
      final result = await balanceRep.transaction(pageKey);

      result.fold(
        (failure) {
          pagingController.error = failure.errMessage;
          emit(TransactionError(failure.errMessage));
        },
        (response) {
          final transactions = response.data ?? [];
          final isLastPage = pageKey >= (response.lastPage ?? 1);

          if (isLastPage) {
            pagingController.appendLastPage(transactions);
          } else {
            final nextPageKey = pageKey + 1;
            pagingController.appendPage(transactions, nextPageKey);
          }
        },
      );
    } catch (e) {
      pagingController.error = e.toString();
      emit(TransactionError(e.toString()));
    }
  }

  void refresh() {
    pagingController.refresh();
  }

  @override
  Future<void> close() {
    pagingController.dispose();
    return super.close();
  }
}
