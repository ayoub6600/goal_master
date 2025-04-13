import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo.dart';
import 'package:goal_master/utils/input_validator.dart';
import 'package:meta/meta.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._repo, this.token) : super(ChangePasswordInitial());
  final AuthRepo _repo;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final String token;

  Future<void> changePassword() async {
    emit(ChangePasswordLoading());
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    var isValid = _validate(password, confirmPassword);
    if (!isValid) return;
    var result = await _repo.changePassword(
      password: password,
      passwordConfirm: confirmPassword,
      token: token,
    );
    result.fold(
      (error) {
        emit(ChangePasswordError(message: error.errMessage));
      },
      (message) => emit(ChangePasswordSuccess(
        message: message,
      )),
    );
  }

  bool _validate(String password, String confirmPassword) {
    String? passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      emit(ChangePasswordError(message: passwordError));
      return false;
    }
    String? confirmPasswordError =
        InputValidator.validateConfirmPassword(password, confirmPassword);
    if (confirmPasswordError != null) {
      emit(ChangePasswordError(message: confirmPasswordError));
      return false;
    }
    return true;
  }
}
