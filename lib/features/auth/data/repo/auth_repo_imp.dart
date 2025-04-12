import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';
import 'package:goal_master/core/utils/functions/auth_manager.dart';
import 'package:goal_master/features/auth/data/model/login_model/login_model.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiConsumer consumer;
  AuthRepoImpl(this.consumer);
  @override
  Future<Either<Failure, UserData>> login({
    required String phone,
    required String password,
  }) async {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.login, data: {
        'phone_number': phone,
        'password': password,
      }),
      (res) async {
        var data = res['data'];
        var user = data['user'];
        var token = data['token'];
        SharedPreferenceUtil.putString(PrefKey.fcmToken, "${token}");
        var model = UserData.fromJson(data);
        print("----------->user: $user, token: $token");

        // AuthManager.saveUser(user.data?.user, user.data?.token);
        // await userInfoCubit.setUser(user, token, token);

        return model;
      },
    );
  }

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
                  'code': otp,
                  'forget': 1,
                }
              : {
                  'phone': phone,
                  'code': otp,
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
        //await userInfoCubit.setUser(model.data?.user, model.data!.token);
        // await userInfoCubit.setUser(model.user, model.token);
        return model;
      },
    );
  }

  @override
  Future<Either<Failure, String>> changePassword(
      {required String password,
      required String passwordConfirm,
      required String token}) {
    return consumer.handleRequestCustom(
      () => consumer.post(EndPoints.changePassword, data: {
        'password': password,
        'password_confirmation': passwordConfirm,
        'token': token,
      }),
      (res) async {
        var message = res['message'];
        return message;
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    // await userInfoCubit.logout();
    return right(unit);
  }

  @override
  Future<Either<Failure, String>> profile() {
    return consumer.handleRequest(
      () => consumer.get(EndPoints.refresh),
      (p0) {
        // Extract the token from the 'data' field
        String token = p0['data']['token'];
        return token; // Return the token as the result
      },
    );
  }
}
