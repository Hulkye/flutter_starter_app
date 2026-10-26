import 'package:flutter/material.dart';
import 'package:flutter_starter_app/core/router/adapters/go_router/router_navigator.dart'
    as go_router;
import 'package:flutter_starter_app/core/router/router.dart' as app_router;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;
  late go_router.RouterNavigator navigator;

  setUp(() {
    router = GoRouter(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );
    navigator = go_router.RouterNavigator(router);
  });

  tearDown(() => router.dispose());

  test('rejects external locations for every navigation operation', () {
    const target = app_router.AppRouteTargetValue(
      location: 'https://example.com',
    );

    expect(() => navigator.go(target), throwsStateError);
    expect(() => navigator.push(target), throwsStateError);
    expect(() => navigator.replace(target), throwsStateError);
    expect(() => navigator.replaceAll(target), throwsStateError);
  });

  test('accepts an internal root location', () {
    const target = app_router.AppRouteTargetValue(location: '/');

    expect(() => navigator.go(target), returnsNormally);
  });
}
