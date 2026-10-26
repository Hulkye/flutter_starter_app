import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../definitions/app_page_route.dart';
import '../definitions/app_redirect_route.dart';
import '../definitions/app_route_metadata.dart';
import '../definitions/app_route_node.dart';
import '../definitions/app_route_state.dart';
import '../definitions/app_shell_route.dart';
import '../guards/app_route_request.dart';
import '../guards/route_access_decision.dart';
import '../guards/router_guard.dart';

/// GoRouter redirect 回调与项目访问决策之间的适配器。
GoRouterRedirect createGoRouterAccessGuard({
  required RouteAccessDecision Function(AppRouteRequest) accessDecision,
  required List<AppRouteNode> routeNodes,
  List<String> publicPaths = const <String>['/'],
  String redirectQueryParameter = 'redirect',
}) {
  return (BuildContext context, GoRouterState state) {
    final routeState = AppRouteState(
      location: state.uri.toString(),
      pathParameters: state.pathParameters,
      queryParameters: state.uri.queryParameters,
      extra: state.extra,
    );
    final matchedRoutePath = state.fullPath;
    if (matchedRoutePath == null) return null;
    final route = _findRoute(routeNodes, matchedRoutePath);
    if (route == null) return null;
    final request = AppRouteRequest(
      location: state.uri.toString(),
      routeKey: route.key,
      metadata: route.metadata,
      state: routeState,
    );
    return resolveAccessRedirect(
      currentLocation: state.uri.toString(),
      matchedRoutePath: matchedRoutePath,
      decision: accessDecision(request),
      publicPaths: publicPaths,
      redirectQueryParameter: redirectQueryParameter,
    );
  };
}

_RouteReference? _findRoute(List<AppRouteNode> nodes, String matchedRoutePath) {
  for (final node in nodes) {
    if (node is AppPageRoute<dynamic> && node.path == matchedRoutePath) {
      return _RouteReference(node.metadata.key, node.metadata);
    }
    if (node is AppRedirectRoute && node.path == matchedRoutePath) {
      return _RouteReference(node.metadata.key, node.metadata);
    }
    if (node is AppShellRoute) {
      final branchRoute = _findRoute([
        for (final branch in node.branches) ...branch.routes,
      ], matchedRoutePath);
      if (branchRoute != null) return branchRoute;
    }
  }
  return null;
}

final class _RouteReference {
  const _RouteReference(this.key, this.metadata);

  final String key;
  final AppRouteMetadata metadata;
}
