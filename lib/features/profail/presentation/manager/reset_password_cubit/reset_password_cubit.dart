import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
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
      (data) {
        _saveUserData(data);
        emit(ResetPasswordSuccess(user: data));
      },
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

  @override
  Future<void> close() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordConformationController.dispose();
    return super.close();
  }
}
