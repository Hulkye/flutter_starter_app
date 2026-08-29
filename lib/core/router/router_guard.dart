import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_access_decision.dart';

bool _matchesRoutePattern(String pattern, String currentPath) {
  if (pattern == currentPath) return true;

  final patternSegments = pattern.split('/');
  final currentSegments = currentPath.split('/');
  if (patternSegments.length != currentSegments.length) return false;

  for (var i = 0; i < patternSegments.length; i++) {
    final patternSegment = patternSegments[i];
    final currentSegment = currentSegments[i];
    if (patternSegment.isEmpty && currentSegment.isEmpty) {
      continue;
    }
    if (patternSegment.startsWith(':')) {
      if (currentSegment.isEmpty) return false;
      continue;
    }
    if (patternSegment != currentSegment) return false;
  }

  return true;
}

/// 创建认证路由守卫。
///
/// 返回的函数直接传给 [GoRouter.redirect]。
///
/// [publicPaths] 中的路径无需登录即可访问，默认只放行主页 `/`。
///
/// 支持 GoRouter 风格的动态片段匹配，例如 `/article/:id` 可以放行
/// `/article/42`。
GoRouterRedirect createAuthGuard({
  required String loginPath,
  required bool Function() isAuthenticated,
  List<String> publicPaths = const <String>['/'],
}) {
  return (BuildContext context, GoRouterState state) {
    final currentPath = state.uri.path;

    // 公开路径 → 放行
    if (publicPaths.any((path) => _matchesRoutePattern(path, currentPath))) {
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
  required RouteAccessDecision Function() accessDecision,
  List<String> publicPaths = const <String>['/'],
  String redirectQueryParameter = 'redirect',
}) {
  return (BuildContext context, GoRouterState state) {
    return resolveAccessRedirect(
      currentLocation: state.uri.toString(),
      decision: accessDecision(),
      publicPaths: publicPaths,
      redirectQueryParameter: redirectQueryParameter,
    );
  };
}

/// 根据当前 location 和最终访问决策计算重定向目标。
String? resolveAccessRedirect({
  required String currentLocation,
  required RouteAccessDecision decision,
  List<String> publicPaths = const <String>['/'],
  String redirectQueryParameter = 'redirect',
}) {
  final currentUri = Uri.parse(currentLocation);
  final currentPath = currentUri.path;

  return switch (decision) {
    AllowRoute(:final redirects) => _resolveAllowedRedirect(
      currentPath,
      redirects,
    ),
    RedirectRoute(
      :final location,
      :final preserveTarget,
      :final appliesToPublicRoutes,
    ) =>
      _resolveRequiredRedirect(
        currentUri: currentUri,
        currentPath: currentPath,
        targetLocation: location,
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
  String currentPath,
  Map<String, String> redirects,
) {
  for (final entry in redirects.entries) {
    _requireInternalLocation(entry.key);
    _requireInternalLocation(entry.value);
    if (_matchesRoutePattern(entry.key, currentPath)) return entry.value;
  }
  return null;
}

String? _resolveRequiredRedirect({
  required Uri currentUri,
  required String currentPath,
  required String targetLocation,
  required bool preserveTarget,
  required bool appliesToPublicRoutes,
  required List<String> publicPaths,
  required String redirectQueryParameter,
}) {
  _requireInternalLocation(targetLocation);
  final targetUri = Uri.parse(targetLocation);
  if (_matchesRoutePattern(targetUri.path, currentPath)) return null;

  final isPublic = publicPaths.any(
    (path) => _matchesRoutePattern(path, currentPath),
  );
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
