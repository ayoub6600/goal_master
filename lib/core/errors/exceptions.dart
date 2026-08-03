import 'package:dio/dio.dart';
import 'failure.dart';

class ServerFailure extends Failure {
  ServerFailure({required super.errMessage});

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(errMessage: 'Connection timeout with ApiServer');
      case DioExceptionType.sendTimeout:
        return ServerFailure(errMessage: 'Send timeout with ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure(errMessage: 'Receive timeout with ApiServer');
      case DioExceptionType.badCertificate:
        return ServerFailure(errMessage: 'Bad Certificate with ApiServer');
      case DioExceptionType.badResponse:
        return ServerFailure.fromBadResponse(
            dioException.response!.statusCode!, dioException.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure(errMessage: 'Request to ApiServer was canceled');
      case DioExceptionType.connectionError:
        return ServerFailure(errMessage: 'Connection error, Please try again!');
      case DioExceptionType.unknown:
        return ServerFailure(errMessage: 'Unexpected error, Please try again!');
      // default:
      //   return ServerFailure(
      //       errMessage: dioException.response?.data ??
      //           'Unexpected error, Please try again!');
    }
  }

  factory ServerFailure.fromBadResponse(int statusCode, dynamic response) {
    if (response is Map<String, dynamic>) {
      final directMessage = response['message'];
      final directData = response['data'];

      if (directMessage is String && directMessage.isNotEmpty) {
        return ServerFailure(errMessage: directMessage);
      }

      if (directData is String && directData.isNotEmpty) {
        return ServerFailure(errMessage: directData);
      }
    }

    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 405 ||
        statusCode == 422) {
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        final errors = response['errors'] as Map<String, dynamic>;
        final messages = errors.values
            .expand((e) => e as List)
            .join('\n'); // دمج كل الرسائل مع فواصل أسطر
        return ServerFailure(errMessage: messages);
      }
      return ServerFailure(errMessage: response['message'] ?? 'خطأ غير متوقع');
    } else if (statusCode == 404) {
      return ServerFailure(
          errMessage: 'لم يتم العثور على الطلب، يرجى المحاولة مرة أخرى!');
    } else if (statusCode == 500) {
      return ServerFailure(
          errMessage: 'خطأ في الخادم الداخلي، يرجى المحاولة لاحقًا!');
    } else {
      return ServerFailure(errMessage: 'حدث خطأ، يرجى المحاولة مرة أخرى!');
    }
  }
}
