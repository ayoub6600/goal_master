import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/features/auth/data/model/onboarding/onboarding_screen_model.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/onboarding/onboarding_artwork.dart';

Widget _host(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('OnboardingScreenModel', () {
    test('blank strings from the panel read as "no override"', () {
      final model = OnboardingScreenModel.fromJson({
        'slug': 'name',
        'title': '   ',
        'subtitle': '',
        'image_url': null,
      });

      expect(model.slug, 'name');
      expect(model.title, isNull);
      expect(model.subtitle, isNull);
      expect(model.imageUrl, isNull);
    });

    test('an override survives parsing intact', () {
      final model = OnboardingScreenModel.fromJson({
        'slug': 'success',
        'title': 'أهلاً بيك',
        'subtitle': 'خطوة وحدة',
        'image_url': 'https://example.test/captain.png',
      });

      expect(model.title, 'أهلاً بيك');
      expect(model.subtitle, 'خطوة وحدة');
      expect(model.imageUrl, 'https://example.test/captain.png');
    });
  });

  group('OnboardingArtwork', () {
    testWidgets('draws nothing when no image is configured', (tester) async {
      await tester.pumpWidget(_host(const OnboardingArtwork(imageUrl: null)));

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('draws nothing for an empty url', (tester) async {
      await tester.pumpWidget(_host(const OnboardingArtwork(imageUrl: '')));

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('steps aside while the keyboard is up', (tester) async {
      // Set on the view rather than on a MediaQuery: the Scaffold below
      // removes the bottom inset from the MediaQuery its body sees, which is
      // exactly the trap this widget has to avoid falling into.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(_host(
        const OnboardingArtwork(imageUrl: 'https://example.test/a.png'),
      ));

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a failing image leaves empty space, never an exception',
        (tester) async {
      await tester.pumpWidget(_host(
        const OnboardingArtwork(imageUrl: 'https://example.test/missing.png'),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
