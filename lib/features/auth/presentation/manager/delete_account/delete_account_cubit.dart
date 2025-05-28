import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:goal_master/features/auth/data/repo/auth_repo.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepo authRepo;

  DeleteAccountCubit(this.authRepo) : super(DeleteAccountInitial());

  Future<void> deleteAccount() async {
    emit(DeleteAccountLoading());
    final result = await authRepo.deleteAccount();

    result.fold(
      (failure) => emit(DeleteAccountFailure(failure.errMessage)),
      (_) => emit(DeleteAccountSuccess()),
    );
  }
}
