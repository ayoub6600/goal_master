// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'user_info_cubit.dart';

class UserInfoState {
  final User? user;
  final bool loading;
  final String? token;
  final String? errorMsg;
  const UserInfoState({
    this.user,
    this.loading = false,
    this.token,
    this.errorMsg,
  });

  UserInfoState copyWith({
    User? user,
    bool? loading,
    String? token,
    String? errorMsg,
  }) {
    return UserInfoState(
      user: user,
      loading: loading ?? this.loading,
      token: token,
      errorMsg: errorMsg,
    );
  }

  bool get loggedIn => user != null && token != null;
}
