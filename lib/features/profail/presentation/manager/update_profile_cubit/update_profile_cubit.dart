import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
import 'package:goal_master/features/profail/data/repo/profile_repo.dart';
import 'package:meta/meta.dart';

part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  UpdateProfileCubit(this._profileRepo) : super(UpdateProfileInitial());
  final ProfileRepo _profileRepo;
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> updateProfile() async {
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
      (data) => emit(UpdateProfileSuccess(message: data)),
    );
  }
}
