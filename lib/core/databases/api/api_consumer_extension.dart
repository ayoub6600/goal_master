import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/core/databases/api/api_consumer.dart';
import 'package:goal_master/core/errors/exceptions.dart';
import 'package:goal_master/core/errors/failure.dart';

extension ApiConsumerExtension on ApiConsumer {
  Future<Either<Failure, T>> handleRequest<T>(
    Future Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      var response = await request();

      return right(fromJson(response));
    } catch (e, s) {
      // logger.e(e);
      // logger.e(s);

      if (e is DioException) {
        String? msg = e.response?.data['message'];
        return left(msg != null
            ? Failure(errMessage: msg)
            : ServerFailure.fromDioException(e));
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
      // logger.e(e);
      // logger.e(s);

      if (e is DioException) {
        String? msg = e.response?.data['message'];
        return left(msg != null
            ? Failure(errMessage: msg)
            : ServerFailure.fromDioException(e));
      }
      return left(ServerFailure(errMessage: e.toString()));
    }
  }

  /// Helper function to create FormData for a single file
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

  /// Helper function to create FormData for multiple files
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
