import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';

import 'package:goal_master/features/auth/data/repo/auth_repo.dart';
import 'package:goal_master/utils/input_validator.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo) : super(LoginInitial());

  final AuthRepo _repo;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<void> login() async {
    emit(LoginLoading());
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    var isValid = _validate(email, password);
    if (!isValid) return;

    var result = await _repo.login(phone: email, password: password);
    result.fold(
      (error) {
        emit(LoginError(error.errMessage));
      },
      (user) {
        emit(LoginSuccess());
        print("---->token ${SharedPreferenceUtil.getString(PrefKey.fcmToken)}");
        //save user

        _saveUserData(user);
      },
    );
  }

  Future<void> _saveUserData(UserData userData) async {
    print("---->UserData token ${userData.token}");
    await SharedPreferenceUtil.putString(
        PrefKey.refreshToken, userData.token ?? "");

    await SharedPreferenceUtil.putString(
        PrefKey.fcmToken, userData.token ?? "");
    await SharedPreferenceUtil.putString(
        PrefKey.fullName, userData.user?.name ?? "");
    await SharedPreferenceUtil.putString(
        PrefKey.email, userData.user?.username ?? "");
    await SharedPreferenceUtil.putString(
        PrefKey.phone, userData.user?.phoneNumber ?? "");
    SharedPreferenceUtil.putString(PrefKey.login, "false");
  }

  bool _validate(String phone, String password) {
    String? phoneError = InputValidator.validatePhoneNumber(phone);
    if (phoneError != null) {
      emit(LoginError(phoneError));
      return false;
    }
    String? passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      emit(LoginError(passwordError));
      return false;
    }
    return true;
  }
}

Future<void> wait() async {
  await Future.delayed(Duration(seconds: 2));
}
