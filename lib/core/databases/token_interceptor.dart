import 'package:dio/dio.dart';
import 'package:goal_master/core/manager/user_info_cubit/user_info_cubit.dart';

class TokenInterceptor extends Interceptor {
  const TokenInterceptor();
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
