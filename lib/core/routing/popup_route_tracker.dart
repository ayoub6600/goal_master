import 'package:flutter/widgets.dart';

/// Counts the bottom sheets and dialogs currently open on the app's
/// navigator.
///
/// The Captain Ayoub bubble is drawn above the navigator (from
/// MaterialApp.router's builder), so on its own it sat on top of every sheet
/// and dialog — over their buttons. It hides while this is above zero.
class PopupRouteTracker extends NavigatorObserver {
  PopupRouteTracker._();

  static final instance = PopupRouteTracker._();

  /// How many popup routes (sheets, dialogs, menus) are open right now.
  final ValueNotifier<int> openPopups = ValueNotifier<int>(0);

  void _change(Route<dynamic>? route, int delta) {
    if (route is PopupRoute) {
      final next = openPopups.value + delta;
      openPopups.value = next < 0 ? 0 : next;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _change(route, 1);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _change(route, -1);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _change(route, -1);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _change(oldRoute, -1);
    _change(newRoute, 1);
  }
}
