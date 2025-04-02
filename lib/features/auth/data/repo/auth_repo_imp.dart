import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/auth/data/model/login_model/login_model.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiConsumer consumer;
  AuthRepoImpl(this.consumer);
  @override
  Future<Either<Failure, LoginModel>> login({
    required String email,
    required String password,
  }) async {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.login, data: {
        'username': email,
        'password': password,
      }),
      (res) async {
        var data = res['data'];
        var model = LoginModel.fromJson(data);
        // await userInfoCubit.setUser(model.user, model.token);
        return model;
      },
    );
  }

  // Future<Either<Failure, String>> forgetPassword({
  //   required String email,
  //   required String otp,
  //   required String password,
  //   required String passwordConfirm,
  // }) {
  //   return consumer.handleRequestCustom(
  //     () => consumer.post(EndPoints.resetPassword, data: {
  //       'email': email,
  //       'password': password,
  //       'password_confirmation': passwordConfirm,
  //       'otp': otp,
  //     }),
  //     (res) async {
  //       var message = res['message'];
  //       return message;
  //     },
  //   );
  // }

  @override
  Future<Either<Failure, String>> sendOTP({required String phone}) {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.sendOTP, data: {
        'phone': phone,
      }),
      (res) async {
        var message = res['message'];
        return message;
      },
    );
  }

  @override
  Future<Either<Failure, String>> verifyOTP({
    required String phone,
    required String otp,
    required bool forget,
  }) {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.verifyOTP,
          data: forget
              ? {
                  'phone': phone,
                  'otp': otp,
                }
              : {
                  'phone': phone,
                  'otp': otp,
                }),
      (res) async {
        var message = res['message'];
        return message;
      },
    );
  }

  @override
  Future<Either<Failure, LoginModel>> register(
      {required String name,
      required String username,
      required String password,
      required String passwordConfirm,
      required String phone}) {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.register, data: {
        'name': name,
        'username': username,
        'password': password,
        'password_confirmation': passwordConfirm,
        'phone_number': phone,
      }),
      (res) async {
        var data = res['data'];
        var model = LoginModel.fromJson(data);
        // await userInfoCubit.setUser(model.user, model.token);
        return model;
      },
    );
  }

  // @override
  // Future<Either<Failure, Unit>> logout() async {
  //   await userInfoCubit.logout();
  //   return right(unit);
  // }

  // @override
  // Future<Either<Failure, UserModel>> profile() {
  //   return consumer.handleRequest(
  //     () => consumer.get(EndPoints.profile),
  //     (p0) => UserModel.fromJson(p0['data']),
  //   );
  // }
}
