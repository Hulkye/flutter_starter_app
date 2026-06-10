import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constant/duration_const.dart';
import 'definitions/router_definitions.dart';

/// GoRouter 适配器：把框架无关的 [AppRouteNode] 转换为 [RouteBase]。
RouteBase toRouteBase(AppRouteNode node) {
  if (node is AppPageRoute) return toGoRoute(node);
  if (node is AppRedirectRoute) return _toRedirectRoute(node);
  if (node is AppShellRoute) return _toShellRoute(node);
  throw UnsupportedError('Unsupported route node: ${node.runtimeType}');
}

/// GoRouter 适配器：把框架无关的 [AppPageRoute] 转换为 [GoRoute]。
GoRoute toGoRoute(AppPageRoute route) {
  return GoRoute(
    path: route.path,
    name: route.path,
    pageBuilder: (context, state) {
      return _slideTransition(
        state,
        route.buildPage(context, toAppRouteState(state)),
      );
    },
  );
}

/// 把 GoRouterState 转为框架无关的 [AppRouteState]。
AppRouteState toAppRouteState(GoRouterState state) {
  return AppRouteState(
    location: state.uri.toString(),
    pathParameters: state.pathParameters,
    queryParameters: state.uri.queryParameters,
    extra: state.extra,
  );
}

GoRoute _toRedirectRoute(AppRedirectRoute route) {
  return GoRoute(
    path: route.path,
    name: route.path,
    redirect: (context, state) => route.redirectTo,
  );
}

StatefulShellRoute _toShellRoute(AppShellRoute route) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return route.builder(
        context,
        toAppRouteState(state),
        _NavigationShellAdapter(navigationShell),
      );
    },
    branches: [
      for (final branch in route.branches)
        StatefulShellBranch(
          navigatorKey: branch.navigatorKey,
          initialLocation: branch.initialLocation,
          routes: [for (final route in branch.routes) toGoRoute(route)],
        ),
    ],
  );
}

final class _NavigationShellAdapter implements AppShellNavigator {
  const _NavigationShellAdapter(this._navigationShell);

  final StatefulNavigationShell _navigationShell;

  @override
  int get currentIndex => _navigationShell.currentIndex;

  @override
  Widget get child => _navigationShell;

  @override
  void goBranch(int index, {bool initialLocation = false}) {
    _navigationShell.goBranch(index, initialLocation: initialLocation);
  }
}

/// 统一页面过渡（从右向左滑入）。
Page<dynamic> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<dynamic>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: DurationConst.pageTransition,
    reverseTransitionDuration: DurationConst.pageTransition,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
  );
}
