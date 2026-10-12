import 'package:flutter/widgets.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses route path as the default metadata key and path', () {
    final route = _TestRoute('/profile');

    expect(route.metadata.key, '/profile');
    expect(route.metadata.path, '/profile');
  });
}

final class _TestRoute extends AppPageRoute<void> {
  const _TestRoute(this.path);

  @override
  final String path;

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const SizedBox.shrink();
  }
}
