import 'package:flutter/widgets.dart';

import '../../core/router/router.dart';
import '../../features/features.dart';
import 'root_shell_page.dart';

List<AppRouteNode> buildRootRouteNodes() {
  return <AppRouteNode>[
    RootRoute(),
    if (appFeatureTabs.isNotEmpty) RootShellRoute(),
  ];
}

final class RootRoute extends AppRedirectRoute {
  RootRoute() : super(path: pathValue, redirectTo: _defaultLocation);

  static const String pathValue = '/';

  static String get _defaultLocation {
    if (appFeatureTabs.isNotEmpty) {
      return appFeatureTabs.first.initialLocation;
    }
    return pathValue;
  }

  String get location => path;
}

final class RootShellRoute extends AppShellRoute {
  RootShellRoute() : super(branches: _branches, builder: _build);

  static final List<AppShellBranch> _branches = [
    for (final tab in appFeatureTabs)
      AppShellBranch(
        initialLocation: tab.initialLocation,
        routes: <AppPageRoute>[tab.route],
      ),
  ];

  static Widget _build(
    BuildContext context,
    AppRouteState state,
    AppShellNavigator shellNavigator,
  ) {
    return RootShellPage(shellNavigator: shellNavigator, tabs: appFeatureTabs);
  }
}
