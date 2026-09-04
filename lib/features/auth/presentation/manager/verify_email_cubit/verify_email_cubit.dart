// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/features/auth/data/model/new_password/new_password_model.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/services/push_notification_service.dart';
import 'package:goal_master/features/auth/data/model/verify_otp_model/verify_otp_model.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo.dart';

part 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  VerifyEmailCubit(
    this.repo,
    this.phone, {
    required this.forget,
  }) : super(VerifyEmailInitial()) {
    _initTimer();
    emailController.text = phone;
  }
  final AuthRepo repo;
  final bool forget; // ✅ تحديد إذا كان Forget أو Register

  final String phone;

  final emailController = TextEditingController();
  late Timer timer;
  int _time = 60;
  String get timeString {
    Duration duration = Duration(seconds: _time);
    return '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  bool get allowResend => _time == 0;
  void _initTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isClosed) return;
      if (_time > 0) {
        _time--;
        emit(VerifyEmailInitial());
      } else {
        timer.cancel();
      }
    });
  }

  void resend() async {
    if (!allowResend) return;
    await sendOTP();
    _time = 60;
    _initTimer();
  }

  String otp = '';
  // set otp and emit initial
  void setOTP(String code) {
    emit(VerifyEmailLoading());

    otp = code;
    emit(VerifyEmailInitial());
  }

  Future<void> verifyOTP() async {
    emit(VerifyEmailLoading());

    var result = await repo.verifyOTP(
      phone: phone,
      otp: otp,
      forget: forget,
    );
    result.fold(
      (error) => emit(VerifyEmailError(error.errMessage)),
      (msg) => emit(VerifyEmailSuccess(msg)),
    );
  }

  Future<void> verifyOTPRegister() async {
    emit(VerifyEmailLoading());

    var result = await repo.verifyOTPRegister(
      phone: phone,
      otp: otp,
      forget: forget,
    );
    result.fold((error) => emit(VerifyEmailError(error.errMessage)), (msg) async {
      // Verifying the number is what completes the account, and the API hands
      // back a session for it right here. Storing it is what lets signup end
      // on the home screen instead of on a login form asking for the phone
      // number and password the customer typed one screen ago.
      await _saveSession(msg);
      if (isClosed) return;
      emit(VerifyEmailSuccessRegister(
        msg,
      ));
    });
  }

  Future<void> _saveSession(VerifyOtpModel model) async {
    final token = model.data?.token;
    if (token == null || token.isEmpty) return;

    final user = model.data?.user;
    await SharedPreferenceUtil.putString(PrefKey.refreshToken, token);
    await SharedPreferenceUtil.putString(PrefKey.fcmToken, token);
    await SharedPreferenceUtil.putString(PrefKey.fullName, user?.name ?? '');
    await SharedPreferenceUtil.putString(PrefKey.email, user?.username ?? '');
    await SharedPreferenceUtil.putString(
        PrefKey.phone, user?.phoneNumber ?? phone);
    await SharedPreferenceUtil.putString(PrefKey.login, "true");
    PushNotificationService.registerTokenIfLoggedIn();
  }

  Future<void> sendOTP({
    bool nextPage = true,
  }) async {
    emit(VerifyEmailLoading());
    String phone = emailController.text.trim();
    var result = await repo.sendOTP(
      phone: phone,
    );
    result.fold((error) => emit(VerifyEmailError(error.errMessage)), (msg) {
      emit(VerifyResend(
        msg,
      ));
    });
  }
}
