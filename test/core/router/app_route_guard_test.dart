import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const request = AppRouteRequest(
    location: '/todo',
    routeKey: 'todo',
    metadata: AppRouteMetadata(key: 'todo', path: '/todo'),
    state: AppRouteState(location: '/todo'),
  );

  test('returns the first redirect and stops evaluating later guards', () {
    var laterGuardEvaluated = false;
    final decision = AppRouteGuardChain([
      const _TestGuard(
        RedirectRoute(target: AppRouteTargetValue(location: '/upgrade')),
      ),
      _CallbackGuard(() {
        laterGuardEvaluated = true;
        return const AllowRoute();
      }),
    ]).evaluate(request);

    expect(decision, isA<RedirectRoute>());
    expect((decision as RedirectRoute).target.location, '/upgrade');
    expect(laterGuardEvaluated, isFalse);
  });

  test('merges redirects from all allow decisions', () {
    final decision = AppRouteGuardChain([
      const _TestGuard(
        AllowRoute(redirects: {'/login': AppRouteTargetValue(location: '/')}),
      ),
      const _TestGuard(
        AllowRoute(
          redirects: {'/onboarding': AppRouteTargetValue(location: '/todo')},
        ),
      ),
    ]).evaluate(request);

    expect(decision, isA<AllowRoute>());
    final redirects = (decision as AllowRoute).redirects;
    expect(redirects['/login']?.location, '/');
    expect(redirects['/onboarding']?.location, '/todo');
  });

  test('rejects conflicting redirects for the same route pattern', () {
    expect(
      () => AppRouteGuardChain([
        const _TestGuard(
          AllowRoute(
            redirects: {'/login': AppRouteTargetValue(location: '/todo')},
          ),
        ),
        const _TestGuard(
          AllowRoute(
            redirects: {'/login': AppRouteTargetValue(location: '/profile')},
          ),
        ),
      ]).evaluate(request),
      throwsStateError,
    );
  });

  test('passes route context to guards', () {
    String? observedKey;
    String? observedPath;
    final decision = AppRouteGuardChain([
      _CallbackGuard(
        () {
          return const AllowRoute();
        },
        onRequest: (request) {
          observedKey = request.routeKey;
          observedPath = request.metadata.path;
        },
      ),
    ]).evaluate(request);

    expect(decision, isA<AllowRoute>());
    expect(observedKey, 'todo');
    expect(observedPath, '/todo');
  });
}

final class _TestGuard implements AppRouteGuard {
  const _TestGuard(this.decision);

  final RouteAccessDecision decision;

  @override
  RouteAccessDecision evaluate(AppRouteRequest request) => decision;
}

final class _CallbackGuard implements AppRouteGuard {
  const _CallbackGuard(this.callback, {this.onRequest});

  final RouteAccessDecision Function() callback;
  final void Function(AppRouteRequest request)? onRequest;

  @override
  RouteAccessDecision evaluate(AppRouteRequest request) {
    onRequest?.call(request);
    return callback();
  }
}
