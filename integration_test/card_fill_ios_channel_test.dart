import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('iOS Smart Fill channel is registered on the active Flutter engine',
      () async {
    const channel = MethodChannel('goal_master/card_fill');
    final response = await channel.invokeMapMethod<Object?, Object?>(
      'install',
      {
        'webViewId': -1,
        'script': '/* registration probe; no WebView or payment data */',
        'origins': ['https://npg.moamalat.net:6006'],
      },
    );

    expect(response?['status'], 'native_webview_not_found');
    expect(response?['ok'], isFalse);
  });
}
