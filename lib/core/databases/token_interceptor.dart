import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;

  TokenInterceptor(this.dio);

  // void _redirectToLogin() async {
  //   await SharedPreferenceUtil.clear();

  //   // المستخدم الآن يعتبر غير مسجل دخول
  //   await SharedPreferenceUtil.putString(PrefKey.login, "false");

  //   // بدل ما تودّيه على login، وديه على home
  //   // AppRouter.router.go(RoutesKeys.kHome);
  // }

  static bool _signingOut = false;

  /// The server ended this sign-in for good — the password was changed on
  /// another device, or the account was deleted. Refreshing can't help, so
  /// the session is cleared and the customer is taken to the login screen
  /// once, instead of every screen failing with the same error.
  Future<void> _endRevokedSession() async {
    if (_signingOut) return;
    _signingOut = true;
    try {
      await SharedPreferenceUtil.clear();
      await SharedPreferenceUtil.putString(PrefKey.login, 'false');
      AppRouter.router.go(RoutesKeys.kLogin);
    } finally {
      _signingOut = false;
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final body = err.response?.data;
    if (err.response?.statusCode == 401 &&
        body is Map &&
        body['reason'] == 'session_revoked') {
      await _endRevokedSession();
      handler.next(err);
      return;
    }

    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains("profile") &&
        !_isRefreshing) {
      debugPrint("🔁 Token expired, trying to refresh...");

      _isRefreshing = true;

      final result = await GetIt.I<AuthRepoImpl>().profile();

      await result.fold(
        (failure) async {
          debugPrint("❌ Failed to refresh token: $failure");

          _isRefreshing = false;
          // _redirectToLogin(); // ✅ التحويل إلى login
          handler.reject(err);
        },
        (newToken) async {
          debugPrint("✅ Token refreshed");

          await SharedPreferenceUtil.putString(PrefKey.fcmToken, newToken);

          final opts = err.requestOptions;
          opts.headers["Authorization"] = "Bearer $newToken";

          try {
            final cloneReq = await dio.fetch(opts);
            _isRefreshing = false;
            handler.resolve(cloneReq);
          } catch (e) {
            _isRefreshing = false;
            //  _redirectToLogin(); // لو فشل بعد التحديث برضو نحوله
            handler.reject(err);
          }
        },
      );
    } else {
      handler.next(err);
    }
  }
}
