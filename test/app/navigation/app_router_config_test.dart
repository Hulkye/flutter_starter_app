import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/app/navigation/app_router_config.dart';
import 'package:flutter_starter_app/app/host/app_bootstrap_coordinator.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app router overrides provide config and access decision together', () {
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(),
        appBootstrapCompletedProvider.overrideWith((ref) => true),
        authSessionProvider.overrideWith(() => _TestAuthSessionNotifier(null)),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(appRouterConfigProvider), isA<AppRouterConfig>());
    expect(container.read(routeAccessDecisionProvider), isA<RedirectRoute>());
  });

  test('authenticated app router decision allows login redirect to home', () {
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(),
        appBootstrapCompletedProvider.overrideWith((ref) => true),
        authSessionProvider.overrideWith(
          () => _TestAuthSessionNotifier(const AuthSession(token: 'token')),
        ),
      ],
    );
    addTearDown(container.dispose);

    final decision = container.read(routeAccessDecisionProvider);
    expect(decision, isA<AllowRoute>());
    expect((decision as AllowRoute).redirects, containsPair('/login', '/'));
  });

  test(
    'router providers fail explicitly without app composition overrides',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(() => container.read(appRouterConfigProvider), throwsStateError);
      expect(
        () => container.read(routeAccessDecisionProvider),
        throwsStateError,
      );
    },
  );

  test('bootstrap keeps routing at splash until completion', () {
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(),
        appBootstrapCompletedProvider.overrideWith((ref) => false),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(routeAccessDecisionProvider), isA<RedirectRoute>());
    expect(
      (container.read(routeAccessDecisionProvider) as RedirectRoute).location,
      '/splash',
    );
  });
}

final class _TestAuthSessionNotifier extends AuthSessionNotifier {
  _TestAuthSessionNotifier(this._initialSession);

  final AuthSession? _initialSession;

  @override
  AuthSession? build() => _initialSession;
}
