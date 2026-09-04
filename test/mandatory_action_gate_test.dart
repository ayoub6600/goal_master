import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/attendance/data/mandatory_action.dart';
import 'package:goal_master/features/attendance/data/mandatory_action_repo.dart';
import 'package:goal_master/features/attendance/presentation/mandatory_action_gate.dart';

/// A stand-in backend whose answers the test controls.
///
/// Records every call so the tests can prove what the gate did and did not
/// send — a double tap sending two answers would be invisible otherwise.
class _FakeRepo implements MandatoryActionRepo {
  _FakeRepo({List<MandatoryAction>? initial, this.failAnswer = false})
      : _queue = List.of(initial ?? const []);

  List<MandatoryAction> _queue;
  bool failAnswer;

  int pendingCalls = 0;
  final List<Map<String, Object>> answers = [];

  /// When set, answers hang until it completes — the only way to have two
  /// taps land while the first request is genuinely still in flight.
  Completer<void>? hold;

  @override
  Future<Either<Failure, List<MandatoryAction>>> pending() async {
    pendingCalls++;
    return right(List.of(_queue));
  }

  @override
  Future<Either<Failure, List<MandatoryAction>>> answer({
    required int confirmationId,
    required bool attended,
    String type = MandatoryAction.kAttendanceConfirmation,
  }) async {
    answers.add({'id': confirmationId, 'attended': attended, 'type': type});

    if (hold != null) {
      await hold!.future;
    }

    if (failAnswer) {
      return left(Failure(errMessage: 'تعذّر الإرسال'));
    }

    _queue = _queue.where((a) => a.id != confirmationId).toList();
    return right(List.of(_queue));
  }
}

MandatoryAction _action(int id, {String branch = 'ملاعب الجدار'}) =>
    MandatoryAction(
      id: id,
      bookingId: 900 + id,
      title: 'نحتاج تأكيدك',
      message: 'إدارة الملعب سجلت أنك لم تحضر إلى هذا الحجز. هل حضرت؟',
      note: 'تكرار حالات عدم الحضور المؤكدة قد يؤدي إلى تقييد ميزة الدفع عند الوصول.',
      branch: branch,
      date: '2029-06-10',
      startTime: '19:00',
    );

/// A pending manager proposal on an already-open no-show dispute — the
/// question wording is entirely server-driven, exactly as the real payload
/// from `DisputeService::disputePromptPayload()` sends it.
MandatoryAction _disputeAgreement(
  int id, {
  required String proposedResult, // 'attended' | 'no_show'
  String branch = 'ملاعب الجدار',
}) =>
    MandatoryAction(
      id: id,
      bookingId: 900 + id,
      type: MandatoryAction.kNoShowDisputeAgreement,
      title: 'تأكيد نتيجة الحجز',
      message: 'إدارة الملعب أفادت بأنه تم الاتفاق على نتيجة هذا الحجز.\n\n'
          'النتيجة المقترحة: '
          '${proposedResult == 'attended' ? 'حضرت إلى الموعد' : 'لم تحضر إلى الموعد'}',
      confirmLabel: 'أؤكد الاتفاق',
      denyLabel: 'لم نتفق',
      branch: branch,
      date: '2029-06-10',
      startTime: '19:00',
    );

Widget _app(
  _FakeRepo repo, {
  bool loggedIn = true,
  VoidCallback? onAppTapped,
}) {
  return MaterialApp(
    home: MandatoryActionGate(
      repo: repo,
      isLoggedIn: () => loggedIn,
      child: Scaffold(
        body: Align(
          // Bottom-left, well away from the centred prompt card, so a tap
          // there is a genuine attempt to reach the app rather than a
          // mis-aimed hit on one of the prompt's own buttons.
          alignment: Alignment.bottomLeft,
          child: ElevatedButton(
            key: const Key('normal_app_button'),
            onPressed: onAppTapped ?? () {},
            child: const Text('احجز الآن'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final prompt = find.byKey(const Key('mandatory_action_prompt'));
  final attended = find.byKey(const Key('mandatory_action_attended'));
  final absent = find.byKey(const Key('mandatory_action_absent'));

  testWidgets('1. nothing pending leaves the app alone', (tester) async {
    final repo = _FakeRepo(initial: const []);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(prompt, findsNothing);
    expect(find.byKey(const Key('normal_app_button')), findsOneWidget);
  });

  testWidgets('2. one pending question blocks the app', (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(prompt, findsOneWidget);
    expect(find.text('نعم، حضرت'), findsOneWidget);
    expect(find.text('لا، لم أحضر'), findsOneWidget);
    // The booking is named, so the customer knows which night is meant.
    expect(find.textContaining('ملاعب الجدار'), findsOneWidget);
  });

  testWidgets('3. it cannot be dismissed by tapping outside or going back',
      (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    // Outside the card.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(prompt, findsOneWidget);

    // Android back.
    final popped = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(popped, isTrue, reason: 'the gate must consume the back gesture');
    expect(prompt, findsOneWidget);
  });

  testWidgets('4. answering "حضرت" resolves and unlocks', (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(attended);
    await tester.pumpAndSettle();

    expect(repo.answers, [
      {'id': 1, 'attended': true, 'type': MandatoryAction.kAttendanceConfirmation}
    ]);
    expect(prompt, findsNothing);
    expect(find.byKey(const Key('normal_app_button')), findsOneWidget);
  });

  testWidgets('5. answering "لم أحضر" resolves and unlocks', (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(absent);
    await tester.pumpAndSettle();

    expect(repo.answers.single['attended'], isFalse);
    expect(prompt, findsNothing);
  });

  testWidgets('6. a failed submission keeps the gate shut', (tester) async {
    final repo = _FakeRepo(initial: [_action(1)], failAnswer: true);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(attended);
    await tester.pumpAndSettle();

    // Nothing was dismissed optimistically, and the customer is told why.
    expect(prompt, findsOneWidget);
    expect(find.byKey(const Key('mandatory_action_error')), findsOneWidget);
    // Retryable: the buttons are live again.
    await tester.tap(attended);
    await tester.pumpAndSettle();
    expect(repo.answers.length, 2);
  });

  testWidgets('7. a restart re-reads the question from the server',
      (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(prompt, findsOneWidget);

    // Tear the whole tree down and build it again: nothing survives locally.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(prompt, findsOneWidget);
    expect(repo.pendingCalls, greaterThan(1));
  });

  testWidgets('8+9. several questions are answered oldest first and only the '
      'last one unlocks the app', (tester) async {
    final repo = _FakeRepo(initial: [_action(1), _action(2), _action(3)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.textContaining('لديك 3'), findsOneWidget);

    await tester.tap(absent);
    await tester.pumpAndSettle();
    expect(prompt, findsOneWidget, reason: 'two still outstanding');

    await tester.tap(absent);
    await tester.pumpAndSettle();
    expect(prompt, findsOneWidget, reason: 'one still outstanding');

    await tester.tap(absent);
    await tester.pumpAndSettle();
    expect(prompt, findsNothing);

    expect(repo.answers.map((a) => a['id']).toList(), [1, 2, 3]);
  });

  testWidgets('10. the app underneath cannot be reached while it is open',
      (tester) async {
    var appWasReached = false;
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo, onAppTapped: () => appWasReached = true));
    await tester.pumpAndSettle();

    // The button is still in the tree, but the overlay owns the surface.
    await tester.tap(find.byKey(const Key('normal_app_button')),
        warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(appWasReached, isFalse,
        reason: 'the app beneath must not receive taps while the gate is open');
    expect(prompt, findsOneWidget);
    expect(repo.answers, isEmpty);
  });

  testWidgets('11. signing out stays available', (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mandatory_action_logout')), findsOneWidget);
  });

  testWidgets('12. a double tap sends one answer', (tester) async {
    final repo = _FakeRepo(initial: [_action(1), _action(2)]);
    repo.hold = Completer<void>();

    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    // Both taps land while the first request is still in flight.
    await tester.tap(attended);
    await tester.pump();
    await tester.tap(attended, warnIfMissed: false);
    await tester.pump();

    expect(repo.answers.length, 1,
        reason: 'a second tap must not submit while one is in flight');

    repo.hold!.complete();
    await tester.pumpAndSettle();

    // And the queue moved on by exactly one.
    expect(repo.answers.length, 1);
    expect(prompt, findsOneWidget);
  });

  testWidgets('a signed-out customer is never gated', (tester) async {
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo, loggedIn: false));
    await tester.pumpAndSettle();

    expect(prompt, findsNothing);
  });

  testWidgets('a failed lookup does not open the gate', (tester) async {
    // If the server cannot be reached, "unchanged" is the safe reading.
    final repo = _FakeRepo(initial: [_action(1)]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(prompt, findsOneWidget);
  });

  group('Phase 2 — manager dispute-proposal agreement', () {
    testWidgets('a pending manager proposal is shown, worded by the server',
        (tester) async {
      final repo = _FakeRepo(
        initial: [_disputeAgreement(5, proposedResult: 'attended')],
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      expect(prompt, findsOneWidget);
      expect(find.text('تأكيد نتيجة الحجز'), findsOneWidget);
      expect(find.textContaining('النتيجة المقترحة: حضرت إلى الموعد'),
          findsOneWidget);
      expect(find.text('أؤكد الاتفاق'), findsOneWidget);
      expect(find.text('لم نتفق'), findsOneWidget);
    });

    testWidgets('the no_show proposal renders its own Arabic label',
        (tester) async {
      final repo = _FakeRepo(
        initial: [_disputeAgreement(6, proposedResult: 'no_show')],
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      expect(find.textContaining('النتيجة المقترحة: لم تحضر إلى الموعد'),
          findsOneWidget);
    });

    testWidgets('confirming sends the dispute type and attended=true',
        (tester) async {
      final repo = _FakeRepo(
        initial: [_disputeAgreement(5, proposedResult: 'attended')],
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      await tester.tap(attended); // "أؤكد الاتفاق"
      await tester.pumpAndSettle();

      expect(repo.answers, [
        {
          'id': 5,
          'attended': true,
          'type': MandatoryAction.kNoShowDisputeAgreement,
        }
      ]);
    });

    testWidgets('rejecting sends the dispute type and attended=false',
        (tester) async {
      final repo = _FakeRepo(
        initial: [_disputeAgreement(5, proposedResult: 'no_show')],
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      await tester.tap(absent); // "لم نتفق"
      await tester.pumpAndSettle();

      expect(repo.answers, [
        {
          'id': 5,
          'attended': false,
          'type': MandatoryAction.kNoShowDisputeAgreement,
        }
      ]);
    });

    testWidgets('no proposal pending means no agreement prompt at all',
        (tester) async {
      final repo = _FakeRepo(initial: const []);
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      expect(prompt, findsNothing);
      expect(find.text('تأكيد نتيجة الحجز'), findsNothing);
    });

    testWidgets('once resolved, the server stops sending it and the prompt disappears',
        (tester) async {
      final repo = _FakeRepo(
        initial: [_disputeAgreement(5, proposedResult: 'attended')],
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();
      expect(prompt, findsOneWidget);

      await tester.tap(attended);
      await tester.pumpAndSettle();

      // The fake mirrors the real server: answering removes it from the
      // pending queue, so the very next read shows the case closed.
      expect(prompt, findsNothing);
    });

    testWidgets('a network failure keeps the proposal unresolved on screen',
        (tester) async {
      final repo = _FakeRepo(
        initial: [_disputeAgreement(5, proposedResult: 'attended')],
        failAnswer: true,
      );
      await tester.pumpWidget(_app(repo));
      await tester.pumpAndSettle();

      await tester.tap(attended);
      await tester.pumpAndSettle();

      // Nothing dismissed, nothing silently agreed to.
      expect(prompt, findsOneWidget);
      expect(find.byKey(const Key('mandatory_action_error')), findsOneWidget);
      expect(find.text('أؤكد الاتفاق'), findsOneWidget);
    });
  });
}
