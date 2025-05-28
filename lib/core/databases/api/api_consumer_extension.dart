import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/errors/exceptions.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

extension ApiConsumerExtension on ApiConsumer {
  Future<Either<Failure, T>> handleRequest<T>(
    Future Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      var response = await request();
      return right(fromJson(response));
    } catch (e, s) {
      logger.e('Error in handleRequest', error: e, stackTrace: s);

      if (e is DioException) {
        if (e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data;
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final messages = errors.values.expand((e) => e as List).join('\n');
            return left(Failure(errMessage: messages));
          } else if (data.containsKey('message')) {
            return left(Failure(errMessage: data['message']));
          }
        }
        return left(ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errMessage: e.toString()));
    }
  }

  Future<Either<Failure, T>> handleRequestCustom<T>(
    Future Function() request,
    FutureOr<T> Function(dynamic response) fromJson,
  ) async {
    try {
      var response = await request();
      return right(await fromJson(response));
    } catch (e, s) {
      logger.e('Error in handleRequestCustom', error: e, stackTrace: s);

      if (e is DioException) {
        if (e.response?.data is Map<String, dynamic>) {
          final data = e.response!.data;
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final messages = errors.values.expand((e) => e as List).join('\n');
            return left(Failure(errMessage: messages));
          } else if (data.containsKey('message')) {
            return left(Failure(errMessage: data['message']));
          }
        }
        return left(ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errMessage: e.toString()));
    }
  }

  Future<FormData> createFormDataForSingleFile({
    required File file,
    String fieldName = "file",
  }) async {
    return FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
  }

  Future<FormData> createFormDataForMultipleFiles({
    required List<File> files,
    String fieldName = "files[]",
  }) async {
    List<MultipartFile> fileList = await Future.wait(
      files.map((file) => MultipartFile.fromFile(file.path,
          filename: file.path.split('/').last)),
    );

    return FormData.fromMap({fieldName: fileList});
  }
}
