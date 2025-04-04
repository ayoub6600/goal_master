// ignore_for_file: prefer_const_constructors

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';
import 'package:goal_master/core/utils/functions/auth_manager.dart';
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

    var result = await _repo.login(email: email, password: password);
    result.fold(
      (error) {
        emit(LoginError(error.errMessage));
      },
      (user) {
        emit(LoginSuccess());
        print("---->token ${SharedPreferenceUtil.getString(PrefKey.fcmToken)}");
        //save user
        print("user: ${user.data?.user}, token: ${user.data?.token}");
        print("user: ${user.data?.user}, token: ${user.data?.token}");
      },
    );
  }

  bool _validate(String email, String password) {
    String? emailError = InputValidator.validateEmail(email);
    if (emailError != null) {
      emit(LoginError(emailError));
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
