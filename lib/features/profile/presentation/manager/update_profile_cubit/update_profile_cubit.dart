import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo.dart';
import 'package:meta/meta.dart';

part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit(
    this._profileRepo,
  ) : super(UpdateProfileInitial());
  final ProfileRepo _profileRepo;

  final nameController = TextEditingController(
      text: SharedPreferenceUtil.getString(PrefKey.fullName));
  final usernameController = TextEditingController(
      text: SharedPreferenceUtil.getString(PrefKey.email));
  final phoneController = TextEditingController(
      text: SharedPreferenceUtil.getString(PrefKey.phone));

  Future<void> updateProfile() async {
    if (usernameController.text.isEmpty) {
      usernameController.text = SharedPreferenceUtil.getString(PrefKey.email);
    } else if (nameController.text.isEmpty) {
      nameController.text = SharedPreferenceUtil.getString(PrefKey.fullName);
    } else if (phoneController.text.isEmpty) {
      phoneController.text = SharedPreferenceUtil.getString(PrefKey.phone);
    }
    String name = nameController.text;
    String username = usernameController.text;
    String phone = phoneController.text;
    emit(UpdateProfileLoading());

    final result = await _profileRepo.updateProfile(
      name: name,
      username: username,
      phone: phone,
    );
    result.fold(
      (failure) => emit(UpdateProfileError(errMessage: failure.errMessage)),
      (data) {
        print("data: ${data.user?.name}");
        print("---->UserData token ${data.token}");
        emit(UpdateProfileSuccess(message: data));
        _saveUserData(data);
      },
    );
  }

  Future<void> _saveUserData(UserData userData) async {
    print("---->UserData token ${userData.toString()}");

    // Save user data to SharedPreferences
    await SharedPreferenceUtil.putString(PrefKey.fcmToken, userData.token!);
    await SharedPreferenceUtil.putString(
        PrefKey.fullName, userData.user?.name ?? "");
    await SharedPreferenceUtil.putString(
        PrefKey.email, userData.user?.username ?? "");
    await SharedPreferenceUtil.putString(
        PrefKey.phone, userData.user?.phoneNumber ?? "");
    print(
        "---->UserData token1111 ${SharedPreferenceUtil.getString(PrefKey.fcmToken)}");

    // Update Dio Authorization header immediately after saving token
    String token = SharedPreferenceUtil.getString(PrefKey.fcmToken);
    print("Updated Authorization token: $token");

    // Here you need to directly update Dio's Authorization header

    // يمكنك إضافة المزيد من البيانات حسب الحاجة
  }
}
