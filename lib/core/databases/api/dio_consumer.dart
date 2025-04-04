import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/core/databases/token_interceptor.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_consumer.dart';
import 'end_points.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options.baseUrl = EndPoints.baserUrl;
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';
    String token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3dlYi5nb2FsbWFzdGVycy5vbmxpbmUvYXBpL2xvZ2luIiwiaWF0IjoxNzQzNzI3ODkwLCJleHAiOjE3NDM3MzE0OTAsIm5iZiI6MTc0MzcyNzg5MCwianRpIjoiU0hueEFneHVpTm9UMmI1SCIsInN1YiI6Ijk1IiwicHJ2IjoiMjNiZDVjODk0OWY2MDBhZGIzOWU3MDFjNDAwODcyZGI3YTU5NzZmNyJ9.PKDIr4uf_R7sDRaPQCHW4duSJ8o4tlRNJWoleX8mi0A";
    dio.options.headers['Authorization'] = 'Bearer $token';

    dio.options.headers['accept-language'] = 'ar';

    dio.options.followRedirects = false;
    dio.interceptors.addAll([
      const TokenInterceptor(),
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
