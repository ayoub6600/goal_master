import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/databases/token_interceptor.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/view/no_internet_view.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_consumer.dart';
import 'end_points.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options.baseUrl = EndPoints.baserUrl;
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';

    _setAuthorizationHeader();

    dio.options.headers['accept-language'] = 'ar';
    dio.options.followRedirects = false;

    dio.interceptors.addAll([
      TokenInterceptor(dio),
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        enabled: true,
        requestHeader: true,
        request: true,
      ),
    ]);
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
      if (parentKey.currentState?.canPop() == false) {
        parentKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NoInternetView()),
        );
      }
    }
  }
}
