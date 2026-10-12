import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = AppRouteTargetResolver();

  test('encodes path and query parameters into a target', () {
    final target = resolver.resolve(
      path: '/profile/:userId',
      pathParameters: const <String, String>{'userId': 'user/1'},
      queryParameters: const <String, String>{'tab': 'posts & replies'},
    );

    expect(target.location, '/profile/user%2F1?tab=posts+%26+replies');
    expect(target.extra, isNull);
  });

  test('preserves extra without changing the location', () {
    const extra = _TestExtra();
    final target = resolver.resolve(path: '/web', extra: extra);

    expect(target.location, '/web');
    expect(target.extra, same(extra));
  });

  test('keeps a plain path when no parameters exist', () {
    final target = resolver.resolve(path: '/todo');

    expect(target.location, '/todo');
  });

  test('rejects missing path parameters', () {
    expect(
      () => resolver.resolve(path: '/profile/:userId'),
      throwsArgumentError,
    );
  });

  test('rejects path parameters not declared in the route', () {
    expect(
      () => resolver.resolve(
        path: '/profile/:userId',
        pathParameters: const <String, String>{'userId': '42', 'tab': 'posts'},
      ),
      throwsArgumentError,
    );
  });

  test('rejects empty path parameter values', () {
    expect(
      () => resolver.resolve(
        path: '/profile/:userId',
        pathParameters: const <String, String>{'userId': ''},
      ),
      throwsArgumentError,
    );
  });
}

final class _TestExtra {
  const _TestExtra();
}
