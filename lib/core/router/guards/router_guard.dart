import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../definitions/app_route_target.dart';
import '../definitions/app_route_state.dart';
import '../definitions/app_page_route.dart';
import '../definitions/app_redirect_route.dart';
import '../definitions/app_shell_route.dart';
import '../definitions/app_route_metadata.dart';
import '../definitions/app_route_node.dart';
import 'app_route_request.dart';
import 'route_access_decision.dart';

/// 创建基于最终访问决策的路由守卫。
GoRouterRedirect createAccessGuard({
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
    // Unknown paths are handled by GoRouter's configured error builder.
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

/// 根据当前 location 和最终访问决策计算重定向目标。
String? resolveAccessRedirect({
  required String currentLocation,
  required String matchedRoutePath,
  required RouteAccessDecision decision,
  List<String> publicPaths = const <String>['/'],
  String redirectQueryParameter = 'redirect',
}) {
  final currentUri = Uri.parse(currentLocation);

  return switch (decision) {
    AllowRoute(:final redirects) => _resolveAllowedRedirect(
      matchedRoutePath,
      redirects,
    ),
    RedirectRoute(
      :final target,
      :final preserveTarget,
      :final appliesToPublicRoutes,
    ) =>
      _resolveRequiredRedirect(
        currentUri: currentUri,
        matchedRoutePath: matchedRoutePath,
        targetLocation: target.location,
        preserveTarget: preserveTarget,
        appliesToPublicRoutes: appliesToPublicRoutes,
        publicPaths: publicPaths,
        redirectQueryParameter: redirectQueryParameter,
      ),
  };
}

/// 只允许回跳到当前应用内的根路径。
String? readInternalRedirect(String? value) {
  if (value == null || value.isEmpty) return null;
  return isInternalLocation(value) ? Uri.parse(value).toString() : null;
}

String? _resolveAllowedRedirect(
  String matchedRoutePath,
  Map<String, AppRouteTarget> redirects,
) {
  for (final entry in redirects.entries) {
    _requireInternalLocation(entry.key);
    _requireInternalLocation(entry.value.location);
    if (entry.key == matchedRoutePath) {
      return entry.value.location;
    }
  }
  return null;
}

String? _resolveRequiredRedirect({
  required Uri currentUri,
  required String matchedRoutePath,
  required String targetLocation,
  required bool preserveTarget,
  required bool appliesToPublicRoutes,
  required List<String> publicPaths,
  required String redirectQueryParameter,
}) {
  _requireInternalLocation(targetLocation);
  final targetUri = Uri.parse(targetLocation);
  if (targetUri.path == currentUri.path) return null;

  final isPublic = publicPaths.contains(matchedRoutePath);
  if (isPublic && !appliesToPublicRoutes) return null;

  if (!preserveTarget) return targetLocation;
  return targetUri
      .replace(
        queryParameters: <String, String>{
          ...targetUri.queryParameters,
          redirectQueryParameter: currentUri.toString(),
        },
      )
      .toString();
}

/// 判断 location 是否为应用内根路径。
bool isInternalLocation(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.hasScheme == false &&
      uri.hasAuthority == false &&
      uri.path.startsWith('/');
}

void _requireInternalLocation(String value) {
  if (!isInternalLocation(value)) {
    throw StateError('Route location must be an internal root path: $value');
  }
}
