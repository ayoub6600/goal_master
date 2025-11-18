import 'package:dio/dio.dart';
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

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains("profile") &&
        !_isRefreshing) {
      print("🔁 Token expired, trying to refresh...");

      _isRefreshing = true;

      final result = await GetIt.I<AuthRepoImpl>().profile();

      await result.fold(
        (failure) async {
          print("❌ Failed to refresh token: $failure");

          _isRefreshing = false;
          // _redirectToLogin(); // ✅ التحويل إلى login
          handler.reject(err);
        },
        (newToken) async {
          print("✅ Token refreshed");

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
