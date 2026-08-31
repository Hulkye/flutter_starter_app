import '../../../core/feature/app_tab_entry.dart';
import '../../../core/router/router.dart';
import 'root_shell_page.dart';

List<AppRouteNode> buildRootRouteNodes({required List<AppTabEntry> tabs}) {
  if (tabs.isEmpty) return const <AppRouteNode>[];

  return <AppRouteNode>[
    RootRoute(redirectTo: tabs.first.initialLocation),
    RootShellRoute(tabs: tabs),
  ];
}

final class RootRoute extends AppRedirectRoute {
  const RootRoute({required super.redirectTo}) : super(path: pathValue);

  static const String pathValue = '/';
  static const String location = pathValue;
}

final class RootShellRoute extends AppShellRoute {
  RootShellRoute({required List<AppTabEntry> tabs})
    : super(
        branches: _buildBranches(tabs),
        builder: (context, state, shellNavigator) =>
            RootShellPage(shellNavigator: shellNavigator, tabs: tabs),
      );

  static List<AppShellBranch> _buildBranches(List<AppTabEntry> tabs) {
    return <AppShellBranch>[
      for (final tab in tabs)
        AppShellBranch(
          initialLocation: tab.initialLocation,
          routes: <AppPageRoute>[tab.route],
        ),
    ];
  }
}
