import 'package:dio/dio.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';

class TokenInterceptor extends Interceptor {
  const TokenInterceptor();
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null) {
      options.headers['Authorization'] =
          'Bearer ${SharedPreferenceUtil.getString(PrefKey.fcmToken)}';
    }
    super.onRequest(options, handler);
  }
}
