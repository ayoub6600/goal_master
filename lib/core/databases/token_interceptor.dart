import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';

import 'package:goal_master/features/auth/data/repo/auth_repo_imp.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false; // متغير للتأكد إذا كان في عملية refresh بالفعل

  TokenInterceptor(this.dio);

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // لو التوكن منتهي و الطلب مش للـ refresh نفسه و مفيش محاولة تحديث سابقة
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains("profile") &&
        !_isRefreshing) {
      print("🔁 Token expired, trying to refresh...");

      _isRefreshing = true; // نعلم إنه فيه محاولة لتحديث التوكن

      final result = await GetIt.I<AuthRepoImpl>().profile();

      await result.fold(
        (failure) async {
          print("❌ Failed to refresh token: $failure");

          _isRefreshing = false; // إعادة تعيين المتغير بعد الفشل
          handler.reject(err);
        },
        (newToken) async {
          print("✅ Token refreshed");

          // خزّن التوكن الجديد
          await SharedPreferenceUtil.putString(PrefKey.fcmToken, newToken);

          // إعادة المحاولة بنفس الطلب السابق
          final opts = err.requestOptions;
          opts.headers["Authorization"] = "Bearer $newToken";

          try {
            final cloneReq = await dio.fetch(opts);
            _isRefreshing = false; // إعادة تعيين المتغير بعد النجاح
            handler.resolve(cloneReq);
          } catch (e) {
            _isRefreshing = false; // إعادة تعيين المتغير بعد الفشل
            handler.reject(err);
          }
        },
      );
    } else {
      // لو مش 401 أو هو نفسه refresh، كمل طبيعي
      handler.next(err);
    }
  }
}
