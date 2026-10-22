import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:goal_master/features/card/presentation/view/widgets/card_fill_bridge.dart';
import 'package:goal_master/features/saved_cards/data/card_vault.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'selected card lookup is id-specific and scoped to the current customer owner',
      () async {
    final store = MemorySecretStore();
    final customerVault = CardVault(store: store, ownerId: 'customer:41');
    final otherVault = CardVault(store: store, ownerId: 'customer:42');
    final first = await customerVault.add(
        holderName: 'First Test',
        number: '4111111111111111',
        expMonth: 12,
        expYear: 2030);
    final selected = await customerVault.add(
        holderName: 'Selected Test',
        number: '5555555555554444',
        expMonth: 7,
        expYear: 2031);
    await otherVault.add(
        holderName: 'Other Owner',
        number: '4000000000000002',
        expMonth: 8,
        expYear: 2032);

    expect(
        (await customerVault.byId(selected.id))?.holderName, 'Selected Test');
    expect((await customerVault.byId(first.id))?.id, first.id);
    expect(await otherVault.byId(selected.id), isNull);
    expect(await customerVault.byId('not-a-card'), isNull);
    final summaries = await customerVault.loadSummaries();
    expect(summaries.first.id, first.id);
    expect(summaries.first.last4, '1111');
    expect(summaries.first.masked, '**** **** **** 1111');
    expect(summaries.first.toString(), isNot(contains('4111111111111111')));
  });

  test('native bridge result accepts only safe field status labels', () {
    final result = CardFillResult.from({
      'ok': true,
      'pan': 'filled',
      'exp': 'filled',
      'name': 'filled',
      'terms': 'checked',
      'cvv': 'untouched',
      'number': '4111111111111111',
    });
    expect(result.ok, isTrue);
    expect(result.pan, 'filled');
    expect(result.terms, 'checked');
    expect(result.cvv, 'untouched');
    expect(result.toString(), isNot(contains('4111111111111111')));
  });

  test('install request failures are not mislabeled as script failures',
      () async {
    const channel = MethodChannel('goal_master/card_fill');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            channel,
            (call) async => {
                  'ok': false,
                  'status': 'invalid_origin_rules',
                  'operation': 'addJavaScriptOnEvent',
                  'exceptionType': 'IllegalArgumentException',
                  'safeReason': 'safe test reason',
                });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    final result = await CardFillBridge.instance.install(12);

    expect(result.supported, isFalse);
    expect(result.diagnosticCode, 'INVALID_INSTALL_REQUEST');
    expect(result.diagnosticDetail,
        'addJavaScriptOnEvent / IllegalArgumentException / safe test reason');
  });

  test('legacy boolean native response is identified as a protocol mismatch',
      () async {
    const channel = MethodChannel('goal_master/card_fill');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => true);
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    final result = await CardFillBridge.instance.install(12);

    expect(result.supported, isFalse);
    expect(result.diagnosticCode, 'BRIDGE_RESPONSE_INVALID');
    expect(result.diagnosticDetail, startsWith('install_response / '));
  });
}
