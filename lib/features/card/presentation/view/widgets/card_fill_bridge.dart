import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'card_fill_script.dart';

class CardFillResult {
  const CardFillResult(
      {required this.ok,
      this.pan,
      this.exp,
      this.name,
      this.terms,
      this.cvv,
      this.reason});
  final bool ok;
  final String? pan;
  final String? exp;
  final String? name;
  final String? terms;
  final String? cvv;
  final String? reason;

  String get diagnosticCode {
    if (ok &&
        pan == 'filled' &&
        exp == 'filled' &&
        name == 'filled' &&
        cvv == 'untouched') {
      return 'FILL_SUCCESS';
    }
    return switch (reason) {
      'no_ready_frame' || 'unknown_form' => 'FORM_NOT_DETECTED',
      'channel_missing' => 'CHANNEL_MISSING',
      _ => 'FILL_FAILED',
    };
  }

  factory CardFillResult.from(Object? value) {
    if (value is! Map) {
      return const CardFillResult(ok: false, reason: 'bridge_error');
    }
    String? safe(String key) =>
        value[key] is String ? value[key] as String : null;
    return CardFillResult(
        ok: value['ok'] == true,
        pan: safe('pan'),
        exp: safe('exp'),
        name: safe('name'),
        terms: safe('terms'),
        cvv: safe('cvv'),
        reason: safe('reason'));
  }
}

class CardFillEvent {
  const CardFillEvent(this.webViewId, this.state);
  final int webViewId;
  final String state;
}

class CardFillInstallResult {
  const CardFillInstallResult(
      {required this.supported,
      required this.diagnosticCode,
      this.diagnosticDetail});
  final bool supported;
  final String diagnosticCode;
  final String? diagnosticDetail;
}

class CardFillBridge {
  CardFillBridge._() {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'state' || call.arguments is! Map) return null;
      final args = call.arguments as Map;
      if (args['webViewId'] is int && args['state'] is String) {
        _events.add(
            CardFillEvent(args['webViewId'] as int, args['state'] as String));
      }
      return null;
    });
  }

  static final CardFillBridge instance = CardFillBridge._();
  final MethodChannel _channel = const MethodChannel('goal_master/card_fill');
  final StreamController<CardFillEvent> _events = StreamController.broadcast();
  Stream<CardFillEvent> get events => _events.stream;

  Future<CardFillInstallResult> install(int id) async {
    // Platform-view creation can lag the controller identifier during startup.
    // Retry only that transient state; capability failures remain explicit.
    for (var attempt = 0; attempt < 5; attempt++) {
      Map<Object?, Object?>? response;
      try {
        response = await _channel.invokeMapMethod<Object?, Object?>('install', {
          'webViewId': id,
          'script': buildMoamalatCardFillScript(),
          'origins': moamalatCardOrigins,
        });
      } on PlatformException catch (error) {
        _logInstallStatus('platform_channel_error_${error.code}');
        return const CardFillInstallResult(
            supported: false, diagnosticCode: 'CHANNEL_MISSING');
      } on MissingPluginException {
        _logInstallStatus('method_channel_missing');
        return const CardFillInstallResult(
            supported: false, diagnosticCode: 'CHANNEL_MISSING');
      } catch (error) {
        final type = error.runtimeType.toString();
        _logInstallStatus('native_response_invalid', type);
        return CardFillInstallResult(
          supported: false,
          diagnosticCode: 'BRIDGE_RESPONSE_INVALID',
          diagnosticDetail: kDebugMode ? 'install_response / $type' : null,
        );
      }
      final status = response?['status'] as String? ?? 'empty_native_response';
      final detail = _safeInstallDetail(response);
      _logInstallStatus(status, detail);
      if (response?['ok'] == true) {
        return const CardFillInstallResult(
            supported: true, diagnosticCode: 'BRIDGE_READY');
      }
      if (!const {'webview_not_registered', 'native_webview_not_found'}
              .contains(status) ||
          attempt == 4) {
        return CardFillInstallResult(
            supported: false,
            diagnosticCode: _installCode(status),
            diagnosticDetail: detail);
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    return const CardFillInstallResult(
        supported: false, diagnosticCode: 'WEBVIEW_NOT_FOUND');
  }

  String _installCode(String status) => switch (status) {
        'missing_webview_id' => 'WEBVIEW_ID_MISSING',
        'webview_not_registered' ||
        'native_webview_not_found' =>
          'NATIVE_WEBVIEW_NOT_FOUND',
        'plugin_not_registered' => 'PLUGIN_NOT_REGISTERED',
        'wrong_plugin_registry' => 'WRONG_PLUGIN_REGISTRY',
        'ios_version_unsupported' => 'FEATURE_UNSUPPORTED',
        'web_message_listener_unsupported' ||
        'document_start_script_unsupported' ||
        'frame_world_injection_unsupported' =>
          'FEATURE_UNSUPPORTED',
        'script_install_failed' => 'SCRIPT_INSTALL_FAILED',
        'invalid_request' ||
        'invalid_origin_rules' =>
          'INVALID_INSTALL_REQUEST',
        'empty_script' => 'SCRIPT_MISSING',
        'origin_not_allowlisted' => 'ORIGIN_MISMATCH',
        'empty_native_response' => 'NATIVE_EMPTY_RESPONSE',
        'bridge_response_invalid' => 'BRIDGE_RESPONSE_INVALID',
        _ => 'SCRIPT_INSTALL_FAILED',
      };

  String? _safeInstallDetail(Map<Object?, Object?>? response) {
    if (!kDebugMode || response == null) return null;
    final operation = response['operation'];
    final exception = response['exceptionType'];
    final reason = response['safeReason'];
    final parts = <String>[
      if (operation is String) operation,
      if (exception is String) exception,
      if (reason is String) reason,
    ];
    return parts.isEmpty ? null : parts.join(' / ');
  }

  void _logInstallStatus(String status, [String? detail]) {
    if (kDebugMode) {
      debugPrint(
          'card_fill_install_status:$status${detail == null ? '' : ':$detail'}');
    }
  }

  Future<void> markClipboardSensitive(String text) async {
    if (!kDebugMode || !Platform.isAndroid) return;
    await _channel.invokeMethod<bool>(
        'markClipboardSensitive', <String, Object>{'text': text});
  }

  Future<CardFillResult> fill(
      {required int id,
      required String pan,
      required String expiry,
      required String name,
      required bool acceptTerms}) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return const CardFillResult(ok: false, reason: 'unsupported_platform');
    }
    try {
      final value = await _channel.invokeMethod<Object?>('fill', {
        'webViewId': id,
        'pan': pan,
        'exp': expiry,
        'name': name,
        'acceptTerms': acceptTerms,
      });
      return CardFillResult.from(value);
    } on PlatformException {
      return const CardFillResult(ok: false, reason: 'fill_failed');
    } on MissingPluginException {
      return const CardFillResult(ok: false, reason: 'channel_missing');
    }
  }

  Future<void> dispose(int id) async {
    try {
      await _channel.invokeMethod<void>('dispose', {'webViewId': id});
    } catch (_) {}
  }
}
