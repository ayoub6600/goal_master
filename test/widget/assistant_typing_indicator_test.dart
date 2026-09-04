import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_typing_indicator.dart';

/// The typing indicator has to survive being built and animated.
///
/// It crashed on first build: two AnimationControllers were vsynced to a
/// State mixing in SingleTickerProviderStateMixin, which permits exactly one.
/// The whole chat screen went red — and an indicator that breaks the screen
/// it was meant to decorate is worse than the plain spinner it replaced.
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('builds without throwing', (tester) async {
    await tester.pumpWidget(host(const AssistantTypingIndicator()));

    expect(tester.takeException(), isNull);
    expect(find.byType(AssistantTypingIndicator), findsOneWidget);
  });

  testWidgets('keeps animating across frames', (tester) async {
    await tester.pumpWidget(host(const AssistantTypingIndicator()));

    // Several frames through the loop — a second ticker would have thrown by
    // now, and so would a controller disposed while still repeating.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('disposes cleanly while still repeating', (tester) async {
    await tester.pumpWidget(host(const AssistantTypingIndicator()));
    await tester.pump(const Duration(milliseconds: 300));

    // Replaced mid-animation, exactly as it is when the reply arrives.
    await tester.pumpWidget(host(const SizedBox()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.byType(AssistantTypingIndicator), findsNothing);
  });

  testWidgets('falls back to an icon when the avatar cannot load',
      (tester) async {
    await tester.pumpWidget(
      host(const AssistantTypingIndicator(avatarUrl: 'https://example.invalid/a.png')),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // A missing picture must not leave a hole, and must not throw.
    expect(tester.takeException(), isNull);
  });
}
