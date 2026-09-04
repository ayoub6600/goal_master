import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/databases/token_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_consumer.dart';
import 'end_points.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options.baseUrl = EndPoints.baserUrl;

    // Says out loud which API this build talks to.
    //
    // Worth a line of output because the base URL is baked in at COMPILE time:
    // a build made without --dart-define is indistinguishable from one made
    // with it until the first request fails, and the failure surfaces as a
    // generic "Connection Error" that says nothing about the address. Printing
    // it once turns "why is it hitting loopback?" into something you can read
    // in the first second of the log.
    if (kDebugMode) {
      debugPrint('API Config → ${EndPoints.baserUrl}'
          '${EndPoints.isLocalApi ? '  (local — pass --dart-define=API_BASE=... for a real device)' : ''}');
    }

    // A release build must never point at a developer's machine.
    //
    // The default base URL is loopback, so a release built without
    // --dart-define=API_BASE would ship an endpoint that resolves to the
    // customer's own phone — every request refused, surfacing as the same
    // generic "Connection Error" that started this investigation. An assert
    // costs nothing in release; it exists so this is caught while building,
    // not after shipping.
    assert(
      !(EndPoints.isLocalApi && const bool.fromEnvironment('dart.vm.product')),
      'Release build is pointing at a local API (${EndPoints.baserUrl}). '
      'Pass --dart-define=API_BASE=https://your-production-host/api/',
    );
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';

    _setAuthorizationHeader();

    dio.options.headers['accept-language'] = 'ar';
    dio.options.followRedirects = false;
    String loginState = SharedPreferenceUtil.getString(PrefKey.login);
    bool isLoggedIn = loginState == "true";

    // 🟦 Always add logger
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        enabled: true,
        requestHeader: true,
        request: true,
      ),
    );

    // 🟥 Add TokenInterceptor ONLY if user is logged in
    if (isLoggedIn) {
      print("🔐 User logged in → TokenInterceptor added");
      dio.interceptors.add(TokenInterceptor(dio));
    } else {
      print("⚠️ User NOT logged in → TokenInterceptor NOT added");
    }
  }

  void _setAuthorizationHeader() {
    String token = SharedPreferenceUtil.getString(PrefKey.fcmToken);
    print("Authorization token: $token");
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  @override
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      _setAuthorizationHeader();
      var response = await dio.post(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _setAuthorizationHeader();
      var res = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _setAuthorizationHeader();
      var res = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = true,
  }) async {
    try {
      _setAuthorizationHeader();
      var res = await dio.patch(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = true,
  }) async {
    try {
      _setAuthorizationHeader();
      var response = await dio.put(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    final isConnectionError = e.type == DioExceptionType.connectionError ||
        e.error is SocketException;

    if (isConnectionError) {
      print('📡 Connection error captured by DioConsumer');
    }
  }
}
