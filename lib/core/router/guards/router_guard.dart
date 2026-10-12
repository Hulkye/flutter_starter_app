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

/// 创建认证路由守卫。
///
/// 返回的函数直接传给 [GoRouter.redirect]。
///
/// [publicPaths] 中的路径无需登录即可访问，默认只放行主页 `/`。
///
/// 公开路由使用 GoRouter 已匹配的 [GoRouterState.fullPath] 判断，避免在
/// Router Guard 内重复实现路径语法。
GoRouterRedirect createAuthGuard({
  required String loginPath,
  required bool Function() isAuthenticated,
  List<String> publicPaths = const <String>['/'],
}) {
  return (BuildContext context, GoRouterState state) {
    final matchedRoutePath = state.fullPath;

    // 公开路径 → 放行
    if (matchedRoutePath != null && publicPaths.contains(matchedRoutePath)) {
      return null;
    }

    // 已登录 → 放行
    if (isAuthenticated()) {
      return null;
    }

    // 未登录 → 重定向到登录页
    return loginPath;
  };
}

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

/// 未登录时禁止访问的便捷守卫。
///
/// 与 [createAuthGuard] 相同，但 publicPaths 默认为空（所有路径都需要登录）。
GoRouterRedirect createStrictAuthGuard({
  required String loginPath,
  required bool Function() isAuthenticated,
}) {
  return createAuthGuard(
    loginPath: loginPath,
    isAuthenticated: isAuthenticated,
    publicPaths: const <String>[],
  );
}
