import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/components/global_app_bar/app_bar_back_button.dart';
import 'package:goal_master/core/routing/routes_keys.dart';

void main() {
  testWidgets('a hidden back button does not react to taps', (tester) async {
    final router = _router(
      home: (_) => const AppBarBackButton(allowBack: false),
    );
    await tester.pumpWidget(_app(router));

    await tester.tap(find.byType(AppBarBackButton));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/');
  });

  testWidgets('back from notifications falls home when there is no history',
      (tester) async {
    final router = _router(
      home: (_) => const Text('home screen'),
      notifications: (_) => const AppBarBackButton(alwaysVisible: true),
    );
    router.go(RoutesKeys.kNotification);
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppBarBackButton));
    await tester.pumpAndSettle();

    expect(find.text('home screen'), findsOneWidget);
  });
}

GoRouter _router({
  required Widget Function(BuildContext) home,
  Widget Function(BuildContext)? notifications,
}) =>
    GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, _) => home(context)),
        GoRoute(
          path: RoutesKeys.kNotification,
          builder: (context, _) =>
              notifications?.call(context) ?? const SizedBox.shrink(),
        ),
        GoRoute(
          path: RoutesKeys.kHome,
          builder: (context, _) => const Text('home screen'),
        ),
      ],
    );

Widget _app(GoRouter router) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
      ),
    );
