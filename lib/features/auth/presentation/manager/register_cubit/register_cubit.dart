import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo.dart';
import 'package:goal_master/utils/input_validator.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repo) : super(RegisterInitial());
  final AuthRepo _repo;
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> register() async {
    emit(RegisterLoading());
    String email = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    String firstName = nameController.text.trim();
    String phone = phoneController.text.trim();
    var isValid = _validate(email, password, firstName, phone);
    if (!isValid) return;
    var result = await _repo.register(
      name: firstName,
      username: email,
      password: password,
      passwordConfirm: confirmPassword,
      phone: phone,
    );
    result.fold((error) {
      emit(RegisterError(error.errMessage));
    }, (user) => emit(RegisterSuccess()));
  }

  bool _validate(
    String email,
    String password,
    String firstName,
    String phone,
  ) {
    String? firstNameError = InputValidator.validateName(firstName);
    if (firstNameError != null) {
      emit(RegisterError(firstNameError));
      return false;
    }

    String? phoneError = InputValidator.validatePhoneNumber(phone);
    if (phoneError != null) {
      emit(RegisterError(phoneError));
      return false;
    }
    String? passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      emit(RegisterError(passwordError));
      return false;
    }

    String? confirmPasswordError = InputValidator.validateConfirmPassword(
        password, confirmPasswordController.text);
    if (confirmPasswordError != null) {
      emit(RegisterError(confirmPasswordError));
      return false;
    }

    return true;
  }
}
