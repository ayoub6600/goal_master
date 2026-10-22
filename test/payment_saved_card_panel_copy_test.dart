import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/card/presentation/view/widgets/payment_saved_card_panel.dart';
import 'package:goal_master/features/saved_cards/data/card_vault.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const clipboardChannel = SystemChannels.platform;
  var clipboard = '';

  setUp(() {
    clipboard = '';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(clipboardChannel, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String? ?? '';
      } else if (call.method == 'Clipboard.getData') {
        return <String, String>{'text': clipboard};
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('goal_master/card_fill'), (call) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(clipboardChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('goal_master/card_fill'), null);
  });

  Future<MemorySecretStore> createStore() async {
    final store = MemorySecretStore();
    await CardVault(store: store, ownerId: 'customer:17').add(
      holderName: 'Synthetic Holder',
      number: '4111111111111111',
      expMonth: 8,
      expYear: 2032,
    );
    await CardVault(store: store, ownerId: 'customer:17').add(
      holderName: 'Selected Holder',
      number: '5555555555554444',
      expMonth: 9,
      expYear: 2033,
    );
    return store;
  }

  Future<void> pumpPanel(
    WidgetTester tester,
    MemorySecretStore store, {
    String Function()? currentOwner,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PaymentSavedCardPanel(
            ownerId: 'customer:17',
            currentOwnerId: currentOwner ?? () => 'customer:17',
            webViewId: null,
            formReady: false,
            bridgeSupported: false,
            diagnosticCode: 'SCRIPT_INSTALL_FAILED',
            vaultStore: store,
            onManageCards: () async {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('copy buttons use selected vault values when Smart Fill fails',
      (tester) async {
    final store = await createStore();
    await pumpPanel(tester, store);

    await tester.tap(find.text('تغيير البطاقة'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Selected Holder').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('5555555555554444'), findsNothing);
    expect(find.textContaining('**** **** **** 4444'), findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('copy-card-number')))
            .onPressed,
        isNotNull);

    await tester.tap(find.byKey(const Key('copy-card-number')));
    await tester.pumpAndSettle();
    expect(clipboard, '5555555555554444');
    expect(find.text('تم نسخ رقم البطاقة'), findsOneWidget);
    expect(find.textContaining('5555555555554444'), findsNothing);

    await tester.tap(find.byKey(const Key('copy-card-expiry')));
    await tester.pumpAndSettle();
    expect(clipboard, '09/33');
    expect(find.text('تم نسخ التاريخ'), findsOneWidget);

    await tester.tap(find.byKey(const Key('copy-card-name')));
    await tester.pumpAndSettle();
    expect(clipboard, 'Selected Holder');
    expect(find.text('تم نسخ الاسم'), findsOneWidget);
  });

  testWidgets('copy revalidates the authenticated owner', (tester) async {
    final store = await createStore();
    await pumpPanel(tester, store, currentOwner: () => 'customer:18');

    await tester.tap(find.byKey(const Key('copy-card-number')));
    await tester.pumpAndSettle();

    expect(clipboard, isEmpty);
    expect(
        find.text('تغير الحساب الحالي؛ أعد فتح صفحة الدفع.'), findsOneWidget);
  });

  testWidgets('clipboard clears after 30 seconds only if unchanged',
      (tester) async {
    final store = await createStore();
    await pumpPanel(tester, store);

    await tester.tap(find.byKey(const Key('copy-card-expiry')));
    await tester.pumpAndSettle();
    expect(clipboard, '08/32');

    clipboard = 'copied by another app';
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(clipboard, 'copied by another app');
  });

  testWidgets('clipboard cleanup clears the same copied value', (tester) async {
    final store = await createStore();
    await pumpPanel(tester, store);

    await tester.tap(find.byKey(const Key('copy-card-number')));
    await tester.pumpAndSettle();
    expect(clipboard, '4111111111111111');

    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(clipboard, isEmpty);
  });
}
