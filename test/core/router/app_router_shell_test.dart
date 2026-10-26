import 'package:flutter/material.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('shell adapter switches branches through app abstraction', (
    tester,
  ) async {
    var selectedIndex = -1;
    final router = GoRouter(
      initialLocation: '/first',
      routes: <RouteBase>[
        toRouteBase(
          AppShellRoute(
            branches: <AppShellBranch>[
              AppShellBranch(
                initialLocation: '/first',
                routes: const <AppPageRoute<dynamic>>[_FirstRoute()],
              ),
              AppShellBranch(
                initialLocation: '/second',
                routes: const <AppPageRoute<dynamic>>[_SecondRoute()],
              ),
            ],
            builder: (context, state, shell) {
              return Column(
                children: <Widget>[
                  Text('branch:${shell.currentIndex}'),
                  shell.child,
                  TextButton(
                    onPressed: () {
                      selectedIndex = 1;
                      shell.goBranch(1);
                    },
                    child: const Text('second tab'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('First page'), findsOneWidget);
    expect(find.text('branch:0'), findsOneWidget);

    await tester.tap(find.text('second tab'));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
    expect(find.text('Second page'), findsOneWidget);
    expect(find.text('branch:1'), findsOneWidget);
  });
}

final class _FirstRoute extends AppPageRoute<void> {
  const _FirstRoute();

  @override
  String get path => '/first';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) => const Text('First page');
}

final class _SecondRoute extends AppPageRoute<void> {
  const _SecondRoute();

  @override
  String get path => '/second';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) =>
      const Text('Second page');
}
