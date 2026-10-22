import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:goal_master/features/card/presentation/view/widgets/card_fill_script.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native bridge fills synthetic card in exact-origin iframe',
      (tester) async {
    const channel = MethodChannel('goal_master/card_fill');
    const frameOrigin = 'http://10.0.2.2:8766';
    const parentOrigin = 'http://10.0.2.2:8765';
    final ready = Completer<void>();
    channel.setMethodCallHandler((call) async {
      if (call.method == 'state' &&
          call.arguments is Map &&
          (call.arguments as Map)['state'] == 'ready' &&
          !ready.isCompleted) {
        ready.complete();
      }
      return null;
    });

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: WebViewWidget(controller: controller)),
    ));
    await tester.pump(const Duration(seconds: 2));
    final platform = controller.platform;
    expect(platform, isA<AndroidWebViewController>());
    final id = (platform as AndroidWebViewController).webViewIdentifier;
    final install = await channel.invokeMapMethod<Object?, Object?>('install', {
      'webViewId': id,
      'script': buildMoamalatCardFillScript(origins: const [frameOrigin]),
      'origins': const [frameOrigin],
    });
    expect(install?['ok'], isTrue, reason: 'native document-start install');

    await controller.loadHtmlString(
      '<!doctype html><iframe src="$frameOrigin/form"></iframe>',
      baseUrl: '$parentOrigin/parent',
    );
    await ready.future.timeout(const Duration(seconds: 15));
    final fill = await channel.invokeMapMethod<Object?, Object?>('fill', {
      'webViewId': id,
      'pan': '4242424242424242',
      'exp': '12/30',
      'name': 'SYNTHETIC TEST',
      'acceptTerms': true,
    }).timeout(const Duration(seconds: 15));
    expect(fill?['ok'], isTrue);
    expect(fill?['pan'], 'filled');
    expect(fill?['exp'], 'filled');
    expect(fill?['name'], 'filled');
    expect(fill?['terms'], 'checked');
    expect(fill?['cvv'], 'untouched');
    expect(fill?['submitted'], isNull);
    channel.setMethodCallHandler(null);
  });
}
