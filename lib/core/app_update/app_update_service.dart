import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:goal_master/core/databases/api/end_points.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateDecision {
  const AppUpdateDecision({
    required this.updateRequired,
    required this.force,
    required this.mode,
    this.deadlineAt,
    this.title,
    this.message,
    this.releaseNotes,
    this.storeUrl,
  });

  final bool updateRequired;
  final bool force;
  final String mode;
  final String? deadlineAt;
  final String? title;
  final String? message;
  final String? releaseNotes;
  final String? storeUrl;

  factory AppUpdateDecision.none() {
    return const AppUpdateDecision(
      updateRequired: false,
      force: false,
      mode: 'none',
    );
  }

  factory AppUpdateDecision.fromJson(Map<String, dynamic> json) {
    return AppUpdateDecision(
      updateRequired: json['update_required'] == true,
      force: json['force'] == true,
      mode: json['mode']?.toString() ?? 'none',
      deadlineAt: json['deadline_at']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      releaseNotes: json['release_notes']?.toString(),
      storeUrl: json['store_url']?.toString(),
    );
  }
}

class AppUpdateService {
  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<AppUpdateDecision> check({required String appKey}) async {
    final platform = _platformKey;
    if (platform == null) return AppUpdateDecision.none();

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await _dio.post(
        '${EndPoints.baserUrl}${EndPoints.appVersionCheck}',
        data: {
          'app': appKey,
          'platform': platform,
          'version_name': packageInfo.version,
          'build_number': int.tryParse(packageInfo.buildNumber),
        },
        options: Options(
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'accept-language': 'ar',
          },
        ),
      );

      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final decision = AppUpdateDecision.fromJson(
          Map<String, dynamic>.from(body['data'] as Map),
        );
        if (kDebugMode) {
          debugPrint(
            'AppUpdate: app=$appKey platform=$platform '
            'version=${packageInfo.version}+${packageInfo.buildNumber} '
            'required=${decision.updateRequired} force=${decision.force} '
            'mode=${decision.mode}',
          );
        }
        return decision;
      }
    } catch (error) {
      // Startup must not fail if the update service is unavailable.
      if (kDebugMode) {
        debugPrint('AppUpdate: check failed: $error');
      }
    }

    return AppUpdateDecision.none();
  }

  String? get _platformKey {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }
}
