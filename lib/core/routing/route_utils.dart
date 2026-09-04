import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<T?> push<T extends Object?>(
  String location,
  BuildContext context, {
  Object? extra,
}) {
  return GoRouter.of(context).push(
    location,
    extra: extra,
  );
}

void go<T extends Object?>(
  String location,
  BuildContext context, {
  Object? extra,
}) {
  return GoRouter.of(context).go(
    location,
    extra: extra,
  );
}

Future<T?> pushReplacement<T extends Object?>(
  String location,
  BuildContext context, {
  Object? extra,
}) {
  return GoRouter.of(context).pushReplacement(
    location,
    extra: extra,
  );
}

void pop<T extends Object?>(BuildContext context, [T? result]) {
  return GoRouter.of(context).pop();
}

/// Whether there is anywhere to go back to.
///
/// A screen reached with [pushReplacement] is alone on the stack, and popping
/// from there throws rather than doing nothing — so any back control on such a
/// screen has to ask first and pick a destination of its own.
bool canPop(BuildContext context) => GoRouter.of(context).canPop();
