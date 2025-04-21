import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
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
    dio.options.headers['Accept'] = 'application/json';
    dio.options.headers['Content-Type'] = 'application/json';

    // تم تحميل التوكن عند تهيئة dio لأول مرة
    _setAuthorizationHeader();

    dio.options.headers['accept-language'] = 'ar';
    dio.options.followRedirects = false;

    dio.interceptors.addAll([
      TokenInterceptor(dio), // إرفاق الـ Interceptor للتعامل مع التوكن
      // ChuckerDioInterceptor(),
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        enabled: true,
        requestHeader: true,
        request: true,
      ),
    ]);
  }

  // إضافة دالة لتحديث التوكن في الهيدر
  void _setAuthorizationHeader() {
    String token = SharedPreferenceUtil.getString(PrefKey.fcmToken);
    print("Authorization token: $token");
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  //!POST
  @override
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    _setAuthorizationHeader(); // تأكد من تحديث التوكن في كل طلب
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
    _setAuthorizationHeader(); // تأكد من تحديث التوكن في كل طلب
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
    _setAuthorizationHeader(); // تأكد من تحديث التوكن في كل طلب
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
    _setAuthorizationHeader(); // تأكد من تحديث التوكن في كل طلب
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
    _setAuthorizationHeader(); // تأكد من تحديث التوكن في كل طلب
    var response = await dio.put(
      path,
      data: isFormData ? FormData.fromMap(data) : data,
      queryParameters: queryParameters,
    );
    return response.data;
  }
}
