import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_app/app/navigation/app_router_config.dart';
import 'package:flutter_starter_app/app/host/app_bootstrap_coordinator.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_feature.dart';
import 'package:flutter_starter_app/core/feature/app_feature_registry.dart';
import 'package:flutter_starter_app/core/feature/app_feature_metadata.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/core/router/integrations/riverpod/router.dart';
import 'package:flutter_starter_app/core/router/integrations/riverpod/router_runtime.dart'
    as go_router;
import 'package:flutter_starter_app/features/features.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final featureRegistry = createAppFeatureRegistry(EnvTag.dev);

  test('app router overrides provide config and access decision together', () {
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(featureRegistry),
        appBootstrapCompletedProvider.overrideWith((ref) => true),
        authSessionProvider.overrideWith(() => _TestAuthSessionNotifier(null)),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(appRouterDefinitionProvider),
      isA<AppRouterDefinition>(),
    );
    final config = container.read(appRouterDefinitionProvider);
    expect(
      config.publicRoutePatterns,
      containsAll(<String>['/login', '/todo', '/splash', '/web']),
    );
    expect(config.observers, contains(ToastUtil.navigatorObserver));
    final decision = container.read(routeAccessDecisionProvider)(
      const AppRouteRequest(
        location: '/todo',
        routeKey: 'todo',
        metadata: AppRouteMetadata(key: 'todo', path: '/todo'),
        state: AppRouteState(location: '/todo'),
      ),
    );
    expect(decision, isA<RedirectRoute>());
  });

  test('authenticated app router decision allows login redirect to home', () {
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(featureRegistry),
        appBootstrapCompletedProvider.overrideWith((ref) => true),
        authSessionProvider.overrideWith(
          () => _TestAuthSessionNotifier(const AuthSession(token: 'token')),
        ),
      ],
    );
    addTearDown(container.dispose);

    final decision = container.read(routeAccessDecisionProvider)(
      const AppRouteRequest(
        location: '/login',
        routeKey: 'auth.login',
        metadata: AppRouteMetadata(key: 'auth.login', path: '/login'),
        state: AppRouteState(location: '/login'),
      ),
    );
    expect(decision, isA<AllowRoute>());
    final redirects = (decision as AllowRoute).redirects;
    expect(redirects, contains('/login'));
    expect(redirects['/login']?.location, '/');
  });

  test('feature guards participate in the final app access decision', () {
    final registry = AppFeatureRegistry(
      environment: EnvTag.dev,
      candidates: <AppFeature>[...appFeatures, const _GuardedFeature()],
    );
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(registry),
        appBootstrapCompletedProvider.overrideWith((ref) => true),
        authSessionProvider.overrideWith(
          () => _TestAuthSessionNotifier(const AuthSession(token: 'token')),
        ),
      ],
    );
    addTearDown(container.dispose);

    final decision = container.read(routeAccessDecisionProvider)(
      const AppRouteRequest(
        location: '/guarded',
        routeKey: '/guarded',
        metadata: AppRouteMetadata(key: '/guarded', path: '/guarded'),
        state: AppRouteState(location: '/guarded'),
      ),
    );

    expect(decision, isA<RedirectRoute>());
    expect((decision as RedirectRoute).target.location, '/upgrade');
  });

  test('unauthenticated access redirects to login before feature guards', () {
    final registry = AppFeatureRegistry(
      environment: EnvTag.dev,
      candidates: <AppFeature>[...appFeatures, const _GuardedFeature()],
    );
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(registry),
        appBootstrapCompletedProvider.overrideWith((ref) => true),
        authSessionProvider.overrideWith(() => _TestAuthSessionNotifier(null)),
      ],
    );
    addTearDown(container.dispose);

    final decision = container.read(routeAccessDecisionProvider)(
      const AppRouteRequest(
        location: '/guarded',
        routeKey: '/guarded',
        metadata: AppRouteMetadata(key: '/guarded', path: '/guarded'),
        state: AppRouteState(location: '/guarded'),
      ),
    );

    expect(decision, isA<RedirectRoute>());
    final redirect = decision as RedirectRoute;
    expect(redirect.target.location, '/login');
    expect(redirect.preserveTarget, isTrue);
  });

  testWidgets('router provider mounts the injected route error builder', (
    tester,
  ) async {
    var renderedErrorLocation = '';
    final container = ProviderContainer(
      overrides: [
        appRouterDefinitionProvider.overrideWith(
          (ref) => AppRouterDefinition(
            routeNodes: const <AppRouteNode>[_GuardedRoute()],
            initialLocation: '/guarded',
            errorBuilder: (context, error) {
              renderedErrorLocation = error.location;
              return Text('Route error: ${error.location}');
            },
          ),
        ),
        routeAccessDecisionProvider.overrideWith(
          (ref) =>
              (request) => const AllowRoute(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(go_router.goRouterProvider);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go('/missing');
    await tester.pumpAndSettle();

    expect(renderedErrorLocation, '/missing');
    expect(find.text('Route error: /missing'), findsOneWidget);
  });

  testWidgets('access decision uses GoRouter matched dynamic route path', (
    tester,
  ) async {
    AppRouteRequest? capturedRequest;
    final container = ProviderContainer(
      overrides: [
        appRouterDefinitionProvider.overrideWith(
          (ref) => const AppRouterDefinition(
            routeNodes: <AppRouteNode>[_DynamicRoute()],
            initialLocation: '/member/42',
          ),
        ),
        routeAccessDecisionProvider.overrideWith(
          (ref) => (request) {
            capturedRequest = request;
            return const AllowRoute();
          },
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(go_router.goRouterProvider);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(capturedRequest?.routeKey, 'member.detail');
    expect(capturedRequest?.metadata.path, '/member/:memberId');
    expect(capturedRequest?.state.pathParameter('memberId'), '42');
    expect(find.text('Member 42'), findsOneWidget);
  });

  test(
    'router providers fail explicitly without app composition overrides',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(appRouterDefinitionProvider),
        throwsStateError,
      );
      expect(
        () => container.read(routeAccessDecisionProvider),
        throwsStateError,
      );
    },
  );

  test('bootstrap keeps routing at splash until completion', () {
    final container = ProviderContainer(
      overrides: [
        ...createAppRouterOverrides(featureRegistry),
        appBootstrapCompletedProvider.overrideWith((ref) => false),
      ],
    );
    addTearDown(container.dispose);

    final decision = container.read(routeAccessDecisionProvider)(
      const AppRouteRequest(
        location: '/splash',
        routeKey: 'app.splash',
        metadata: AppRouteMetadata(key: 'app.splash', path: '/splash'),
        state: AppRouteState(location: '/splash'),
      ),
    );
    expect(decision, isA<RedirectRoute>());
    expect((decision as RedirectRoute).target.location, '/splash');
  });
}

final class _TestAuthSessionNotifier extends AuthSessionNotifier {
  _TestAuthSessionNotifier(this._initialSession);

  final AuthSession? _initialSession;

  @override
  AuthSession? build() => _initialSession;
}

final class _GuardedFeature extends AppFeature {
  const _GuardedFeature();

  @override
  AppFeatureMetadata get metadata =>
      const AppFeatureMetadata(key: 'guarded', priority: 500);

  @override
  List<AppPageRoute<dynamic>> get routes => const <AppPageRoute<dynamic>>[
    _GuardedRoute(),
  ];

  @override
  List<AppRouteGuard> get guards => const <AppRouteGuard>[_GuardedRouteGuard()];
}

final class _GuardedRoute extends AppPageRoute<void> {
  const _GuardedRoute();

  @override
  String get path => '/guarded';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) => const SizedBox.shrink();
}

final class _GuardedRouteGuard implements AppRouteGuard {
  const _GuardedRouteGuard();

  @override
  RouteAccessDecision evaluate(AppRouteRequest request) {
    if (request.routeKey == '/guarded') {
      return const RedirectRoute(
        target: AppRouteTargetValue(location: '/upgrade'),
      );
    }
    return const AllowRoute();
  }
}

final class _DynamicRoute extends AppPageRoute<String> {
  const _DynamicRoute();

  @override
  String get path => '/member/:memberId';

  @override
  AppRouteMetadata get metadata =>
      const AppRouteMetadata(key: 'member.detail', path: '/member/:memberId');

  @override
  String parse(AppRouteState state) => state.requiredPathParameter('memberId');

  @override
  Widget buildPage(BuildContext context, String args) => Text('Member $args');
}
