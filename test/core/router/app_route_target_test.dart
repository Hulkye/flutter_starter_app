import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes a navigation location and optional in-memory extra', () {
    const target = _TestRouteTarget(
      location: '/profile/42',
      extra: 'from-profile',
    );

    expect(target.location, '/profile/42');
    expect(target.extra, 'from-profile');
  });
}

final class _TestRouteTarget implements AppRouteTarget {
  const _TestRouteTarget({required this.location, this.extra});

  @override
  final String location;

  @override
  final Object? extra;
}
