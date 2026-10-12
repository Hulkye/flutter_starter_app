import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/features/auth/presentation/auth_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a safe redirect into typed login arguments', () {
    const route = LoginRoute();

    final args = route.parse(
      const AppRouteState(
        location: '/login?redirect=%2Fprofile%3Ftab%3Dposts',
        queryParameters: <String, String>{'redirect': '/profile?tab=posts'},
      ),
    );

    expect(args, isA<LoginRouteArgs>());
    expect(args.redirectLocation, '/profile?tab=posts');
  });

  test('rejects external redirect in typed route arguments', () {
    const route = LoginRoute();

    final args = route.parse(
      const AppRouteState(
        location: '/login?redirect=https%3A%2F%2Fexample.com',
        queryParameters: <String, String>{'redirect': 'https://example.com'},
      ),
    );

    expect(args.redirectLocation, isNull);
  });
}
