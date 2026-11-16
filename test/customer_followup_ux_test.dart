import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/routing/popup_route_tracker.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/balance/presentation/send_money_cubit/send_money_cubit.dart';
import 'package:goal_master/features/card/presentation/view/transaction_item.dart';

/// Second customer-app pass (2026-11-16).
void main() {
  Transaction tx({
    required int balanceType,
    String? type,
    String? description,
    TxUser? referenceUser,
  }) =>
      Transaction(
        id: 1,
        balanceableType: 'App\\Models\\User',
        balanceableId: 80,
        amount: 120,
        userId: 80,
        balanceType: balanceType,
        type: type,
        description: description,
        status: 1,
        createdAt: DateTime(2026, 11, 16, 19, 24),
        updatedAt: DateTime(2026, 11, 16, 19, 24),
        referenceUser: referenceUser,
      );

  Future<void> pump(WidgetTester tester, Transaction t) async {
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: TransactionItem(transaction: t)),
        ),
      ),
    ));
  }

  testWidgets('a booking refund reads as a refund, not an admin deposit',
      (tester) async {
    await pump(
        tester,
        tx(
            balanceType: 1,
            type: 'credit',
            description: 'استرجاع حجز رقم #100066'));

    expect(find.text('استرجاع'), findsOneWidget);
    expect(find.text('استرجاع حجز'), findsOneWidget);
    expect(find.text('إيداع من الإدارة'), findsNothing);
  });

  testWidgets('paying for a booking reads as a booking payment',
      (tester) async {
    await pump(
        tester,
        tx(
            balanceType: 0,
            type: 'transfer',
            description: 'دفعة حجز رقم #100067 إلى محفظة مدير الملعب'));

    expect(find.text('دفع حجز'), findsNWidgets(2));
    expect(find.text('تحويل صادر'), findsNothing);
  });

  testWidgets('dates are Arabic and a transfer names the other person',
      (tester) async {
    await pump(
        tester,
        tx(
          balanceType: 0,
          type: 'transfer',
          referenceUser: TxUser(
              id: 46, name: 'ولاء', username: 'w', phoneNumber: '0912276728'),
        ));

    expect(find.textContaining('16 نوفمبر 2026'), findsOneWidget);
    expect(find.textContaining('مساءً'), findsOneWidget);
    expect(find.textContaining('إلى ولاء'), findsOneWidget);
    expect(find.textContaining('Nov'), findsNothing);
  });

  testWidgets('sheets and dialogs are counted while open', (tester) async {
    final tracker = PopupRouteTracker.instance;
    final start = tracker.openPopups.value;
    final key = GlobalKey<NavigatorState>();

    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      navigatorObservers: [tracker],
      home: const Scaffold(body: SizedBox()),
    ));

    showModalBottomSheet<void>(
        context: key.currentContext!, builder: (_) => const Text('sheet'));
    await tester.pumpAndSettle();
    expect(tracker.openPopups.value, start + 1);

    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(tracker.openPopups.value, start);
  });

  test('a transfer cannot be confirmed without the account password', () {
    const empty = SendMoneyState(receiver: '0912276728', amount: '10');
    expect(empty.isFormValid, isFalse);

    const ready =
        SendMoneyState(receiver: '0912276728', amount: '10', password: 'x');
    expect(ready.isFormValid, isTrue);
  });

  test('a monthly booking paid in full reads as paid', () {
    // The API's ServicePaymentStatus numbers, and the older words.
    expect(seriesPaymentStatus(1), 'paid');
    expect(seriesPaymentStatus('3'), 'partial');
    expect(seriesPaymentStatus(2), 'unpaid');
    expect(seriesPaymentStatus('paid'), 'paid');
    expect(seriesPaymentStatus(null), 'unpaid');
  });
}
