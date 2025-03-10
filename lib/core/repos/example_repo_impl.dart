import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:goal_master/core/databases/api/api_consumer_extension.dart';
import 'package:goal_master/core/databases/api/dio_consumer.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/repos/example_repo.dart';

class ExampleRepoImpl extends ExampleRepo {
  final DioConsumer apiConsumer;

  ExampleRepoImpl(this.apiConsumer);

  @override
  Future<Either<Failure, String>> fetchID() async {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.id),
      (data) => data['data']['id'],
    );
  }

  @override
  Future<Either<Failure, List<String>>> fetchIDs() {
    return apiConsumer.handleRequest(
      () => apiConsumer.get(EndPoints.id),
      (data) => (data as List).map((e) => e['data']['id'] as String).toList(),
    );
  }

  @override
  Future<Either<Failure, String>> putID(String id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.put(EndPoints.id, data: {'id': id}),
      (data) => data['message'],
    );
  }

  @override
  Future<Either<Failure, String>> deleteID(String id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.delete(EndPoints.id, data: {'id': id}),
      (data) => data['message'],
    );
  }

  @override
  Future<Either<Failure, void>> postID(String id) {
    return apiConsumer.handleRequest(
      () => apiConsumer.post(EndPoints.id, data: {'id': id}),
      (data) {},
    );
  }

  @override
  Future<Either<Failure, String>> uploadSingleFile(File file) {
    return apiConsumer.handleRequest(
      () async {
        FormData formData = await apiConsumer.createFormDataForSingleFile(
          file: file,
        );

        return apiConsumer.post(
          EndPoints.id,
          data: formData,
          isFormData: true,
        );
      },
      (data) => data['message'],
    );
  }

  @override
  Future<Either<Failure, void>> uploadMultipleFiles(List<File> files) {
    return apiConsumer.handleRequest(
      () async {
        FormData formData = await apiConsumer.createFormDataForMultipleFiles(
          files: files,
        );

        return apiConsumer.post(
          EndPoints.id,
          data: formData,
          isFormData: true,
        );
      },
      (data) {},
    );
  }
}
