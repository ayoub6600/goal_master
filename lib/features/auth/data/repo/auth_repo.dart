import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/auth/data/model/login_model/login_model.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
import 'package:goal_master/features/auth/data/model/new_password/new_password_model.dart';
import 'package:goal_master/features/auth/data/model/verify_otp_model/verify_otp_model..dart';

abstract class AuthRepo {
  // Future<Either<Failure, UserModel>> profile();
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserData>> login({
    required String phone,
    required String password,
  });
  Future<Either<Failure, String>> sendOTP({
    required String phone,
  });
  Future<Either<Failure, ResetTokenResponse>> verifyOTP({
    required String phone,
    required String otp,
    required bool forget,
  });
  Future<Either<Failure, VerifyOtpModel>> verifyOTPRegister({
    required String phone,
    required String otp,
    required bool forget,
  });
  Future<Either<Failure, LoginModel>> register({
    required String name,
    required String username,
    required String password,
    required String passwordConfirm,
    required String phone,
  });
  Future<Either<Failure, String>> changePassword({
    required String password,
    required String passwordConfirm,
    required String token,
  });
  Future<Either<Failure, String>> profile();
}
