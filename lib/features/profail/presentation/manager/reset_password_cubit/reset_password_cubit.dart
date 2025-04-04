import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/features/profail/data/repo/profile_repo.dart';
import 'package:goal_master/utils/input_validator.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit(this._profileRepo) : super(ResetPasswordInitial());
  final ProfileRepo _profileRepo;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordConformationController = TextEditingController();

  Future<void> resetPassword() async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    String newPasswordConfirmation = newPasswordConformationController.text;
    var passwordValid = _validatePasswords(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
    if (!passwordValid) return;

    emit(ResetPasswordLoading());
    final result = await _profileRepo.resetPassword(
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
      oldPassword: oldPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordError(errMessage: failure.errMessage)),
      (data) => emit(ResetPasswordSuccess(message: data)),
    );
  }

  bool _validatePasswords({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    var oldPasswordError = InputValidator.validatePassword(oldPassword);
    if (oldPasswordError != null) {
      showCustomFailureToast(oldPasswordError);
      return false;
    }
    var passwordError = InputValidator.validatePassword(newPassword);
    if (passwordError != null) {
      showCustomFailureToast(passwordError);
      return false;
    }
    var passwordConfirmError = InputValidator.validateConfirmPassword(
      newPassword,
      newPasswordConfirmation,
    );
    if (passwordConfirmError != null) {
      showCustomFailureToast(passwordConfirmError);
      return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordConformationController.dispose();
    return super.close();
  }
}
