import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> parentKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellKey = GlobalKey<NavigatorState>();

extension GoRouterExtension on GoRouter {
  // Navigate back to a specific route
  void popUntilPath(BuildContext context, String ancestorPath) {
    while (routerDelegate.currentConfiguration.matches.last.matchedLocation !=
        ancestorPath) {
      if (!context.canPop()) {
        return;
      }
      context.pop();
    }
  }

  static dynamic back([dynamic popValue]) {
    return parentKey.currentState?.pop(popValue);
  }
}

abstract class AppRouter {
  static final router = GoRouter(
    observers: [ChuckerFlutter.navigatorObserver],
    navigatorKey: parentKey,
    routes: appRoutes,
    initialLocation: RoutesKeys.kSplashView,
  );
}
