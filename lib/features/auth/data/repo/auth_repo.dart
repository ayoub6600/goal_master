import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/auth/data/model/login_model/login_model.dart';

abstract class AuthRepo {
  // Future<Either<Failure, UserModel>> profile();
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, LoginModel>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, String>> sendOTP({
    required String phone,
  });
  Future<Either<Failure, String>> verifyOTP({
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
