import 'package:dartz/dartz.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
import 'package:goal_master/features/profile/data/repo/profile_repo.dart';

import '../../../../core/manager/user_info_cubit/user_info_cubit.dart';

class ProfileRepoImp extends ProfileRepo {
  final ApiConsumer consumer;

  ProfileRepoImp(this.consumer);

  @override
  Future<Either<Failure, User>> getProfile() {
    return consumer.handleRequest(
      () => consumer.get(EndPoints.profile),
      (res) {
        var data = res['data']["user"];
        var user = User.fromJson(data);
        return user;
      },
    );
  }

  Future<Either<Failure, UserData>> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return consumer.handleRequest(
      () => consumer.post(
        EndPoints.changePasswordUser,
        data: {
          'password_confirmation': newPasswordConfirmation,
          'password': newPassword,
          "old_password": oldPassword
        },
        isFormData: false,
      ),
      (data) {
        print("token: ${data["data"]["token"]}");
        return UserData.fromJson(data["data"]);
      },
    );
  }

  @override
  Future<Either<Failure, UserData>> updateProfile({
    required String name,
    required String username,
    required String phone,
  }) {
    return consumer.handleRequest(
      () => consumer.post(
        EndPoints.update,
        isFormData: false,
        data: {'name': name, 'username': username, 'phone_number': phone},
      ),
      (data) {
        print("token: ${data["data"]["token"]}");
        return UserData.fromJson(data["data"]);
      },
    );
  } //
}
