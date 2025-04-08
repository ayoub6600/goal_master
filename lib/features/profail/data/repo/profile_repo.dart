import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';

abstract class ProfileRepo {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, String>> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<Either<Failure, UserData>> updateProfile({
    required String name,
    required String username,
    required String phone,
  });
}
