import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String? redirect({
    required String location,
    required RouteAccessDecision decision,
    List<String> publicPaths = const <String>['/login', '/article/:id'],
  }) {
    return resolveAccessRedirect(
      currentLocation: location,
      decision: decision,
      publicPaths: publicPaths,
    );
  }

  test('redirects unauthenticated protected routes with original location', () {
    final result = redirect(
      location: '/todo?filter=open',
      decision: const RedirectRoute(location: '/login', preserveTarget: true),
    );

    expect(result, '/login?redirect=%2Ftodo%3Ffilter%3Dopen');
  });

  test('sends authenticated users away from login', () {
    expect(
      redirect(
        location: '/login',
        decision: const AllowRoute(redirects: {'/login': '/todo'}),
      ),
      '/todo',
    );
  });

  test('allows public dynamic routes without authentication', () {
    expect(
      redirect(
        location: '/article/42',
        decision: const RedirectRoute(location: '/login', preserveTarget: true),
      ),
      isNull,
    );
  });

  test('sends expired tokens to reauthentication', () {
    expect(
      redirect(
        location: '/todo',
        decision: const RedirectRoute(location: '/reauthenticate'),
      ),
      '/reauthenticate',
    );
  });

  test('force upgrade takes priority over ordinary business routes', () {
    expect(
      redirect(
        location: '/todo',
        decision: const RedirectRoute(
          location: '/upgrade',
          appliesToPublicRoutes: true,
        ),
      ),
      '/upgrade',
    );
  });

  test('does not redirect while already on an access state page', () {
    expect(
      redirect(
        location: '/upgrade',
        decision: const RedirectRoute(
          location: '/upgrade',
          appliesToPublicRoutes: true,
        ),
      ),
      isNull,
    );
  });

  test('global redirect decisions override public routes', () {
    expect(
      redirect(
        location: '/article/42',
        decision: const RedirectRoute(
          location: '/upgrade',
          appliesToPublicRoutes: true,
        ),
      ),
      '/upgrade',
    );
  });

  test('accepts only internal redirect locations', () {
    expect(readInternalRedirect('/todo?filter=open'), '/todo?filter=open');
    expect(readInternalRedirect('https://example.com'), isNull);
    expect(readInternalRedirect('//example.com/path'), isNull);
  });

  test('rejects external redirect decisions explicitly', () {
    expect(
      () => resolveAccessRedirect(
        currentLocation: '/todo',
        decision: const RedirectRoute(location: 'https://example.com'),
      ),
      throwsStateError,
    );

    expect(
      () => resolveAccessRedirect(
        currentLocation: '/login',
        decision: const AllowRoute(
          redirects: {'/login': 'https://example.com'},
        ),
      ),
      throwsStateError,
    );
  });

  test('allows ordinary routes without extra state configuration', () {
    expect(
      resolveAccessRedirect(
        currentLocation: '/todo',
        decision: const AllowRoute(),
      ),
      isNull,
    );
  });
}
