import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_consumer.dart';
import 'end_points.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options.baseUrl = EndPoints.baserUrl;
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['authorization'] =
        'Bearer 12|Wu7IYOcLQumoNdV7P4BtkBnD2e3TKmcP3GLwp82jf3934caf';
    dio.options.headers['accept-language'] = 'ar';
    dio.options.headers['Authorization'] =
        'Bearer 67|UY4xmjsDVxJktH6YdmlprbWidCUD1Ir1sdX4Zrzjee44974a';
    dio.options.followRedirects = false;
    dio.interceptors.addAll([
      ChuckerDioInterceptor(),
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        enabled: true,
        requestHeader: true,
        request: true,
      )
    ]);
  }

//!POST
  @override
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    var response = await dio.post(
      path,
      data: isFormData ? FormData.fromMap(data) : data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

//!GET
  @override
  Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var res = await dio.get(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return res.data;
  }

//!DELETE
  @override
  Future delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    var res = await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return res.data;
  }

//!PATCH
  @override
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = true,
  }) async {
    var res = await dio.patch(
      path,
      data: isFormData ? FormData.fromMap(data) : data,
      queryParameters: queryParameters,
    );
    return res.data;
  }

  @override
  Future put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = true,
  }) async {
    var response = await dio.put(
      path,
      data: isFormData ? FormData.fromMap(data) : data,
      queryParameters: queryParameters,
    );
    return response.data;
  }
}
