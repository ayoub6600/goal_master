// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/utils/functions/auth_manager.dart';
import 'package:goal_master/features/auth/data/model/login_model/user.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo.dart';
part 'user_info_state.dart';

var userInfoCubit = parentKey.currentContext!.read<UserInfoCubit>();
String? _token;
String? get token => _token;

class UserInfoCubit extends Cubit<UserInfoState> {
  static void setToken(String? t) {
    _token = t;
  }

  UserInfoCubit(
    this._authRepo,
    // this._profileRepo,
  ) : super(UserInfoState()) {
    _initCubit();
    try {
      //  reloadUserAPI();
    } catch (e) {
      print("------------> $e");
    }
  }
  final AuthRepo _authRepo;
  // final CompleteProfileRepo _profileRepo;

  String? token;
  User? user;
  Future<void> _initCubit() async {
    var user = await AuthManager.getUser();
    var token = await AuthManager.getToken();
    if (user == null && token == null) return;
    await setUser(user, token);
  }

  Future<void> setUser(User? user, String? token) async {
    emit(state.copyWith(loading: true));
    print("------------> $user");
    print("------------> $token");
    await AuthManager.saveUser(user, token);

    this.user = user ?? this.user;
    this.token = token ?? this.token;
    _token = token ?? _token;
    emit(state.copyWith(
      loading: false,
      user: user ?? this.user,
      token: token ?? this.token,
    ));
  }

  Future<void> saveUser(User? user, String? token) async {
    await AuthManager.saveUser(user, token);
  }

  Future<void> logout() async {
    emit(state.copyWith(loading: true));
    await AuthManager.logout();
    user = null;
    token = null;
    _token = null;
    emit(state.copyWith(
      loading: false,
      user: null,
      token: null,
    ));
  }

  // Future<void> reloadUserAPI() async {
  //   emit(state.copyWith(
  //     user: state.user,
  //     token: state.token,
  //     loading: true,
  //   ));
  //   var res = await _authRepo.profile();
  //   res.fold(
  //     (l) {
  //       emit(state.copyWith(
  //         errorMsg: l.errMessage,
  //         loading: false,
  //         user: state.user,
  //         token: state.token,
  //       ));
  //     },
  //     (r) {
  //       setUser(
  //           state.user, r); // Update user and token after successful response
  //     },
  //   );
  // }
}
