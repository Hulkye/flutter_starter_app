import 'package:flutter/widgets.dart';
import 'package:flutter_starter_app/app/navigation/shell/root_shell_route.dart';
import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildRootRouteNodes', () {
    test('does not create root redirect route when tabs are empty', () {
      final nodes = buildRootRouteNodes(tabs: const <AppTabEntry>[]);

      expect(nodes, isEmpty);
    });

    test('creates root redirect and shell route when tabs exist', () {
      final nodes = buildRootRouteNodes(tabs: const <AppTabEntry>[_TestTab()]);

      expect(nodes, hasLength(2));
      expect(
        nodes.first,
        isA<RootRoute>().having(
          (route) => route.redirectTo,
          'redirectTo',
          '/test',
        ),
      );

      final shellRoute = nodes.last as RootShellRoute;
      expect(shellRoute.branches, hasLength(1));
      expect(shellRoute.branches.first.initialLocation, '/test');
      expect(shellRoute.branches.first.routes.single, isA<_TestRoute>());
    });
  });
}

final class _TestTab extends AppTabEntry {
  const _TestTab();

  @override
  String get key => 'test';

  @override
  String label(BuildContext context) => 'Test';

  @override
  String icon(BuildContext context) => 'test';

  @override
  String selectedIcon(BuildContext context) => 'test_selected';

  @override
  AppPageRoute<dynamic> get route => const _TestRoute();

  @override
  AppRouteTarget get initialTarget => const _TestTarget();
}

final class _TestRoute extends AppPageRoute<void> {
  const _TestRoute();

  @override
  String get path => '/test';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const SizedBox.shrink();
  }
}

final class _TestTarget extends AppRouteTargetBase {
  const _TestTarget();

  @override
  String get location => '/test';
}
