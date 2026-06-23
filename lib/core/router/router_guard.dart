import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/services/auth/auth_store.dart';

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
  List<String> publicPaths = const <String>['/'],
}) {
  return (BuildContext context, GoRouterState state) {
    final currentPath = state.uri.path;

    // 公开路径 → 放行
    if (publicPaths.any((path) => _matchesRoutePattern(path, currentPath))) {
      return null;
    }

    // 已登录 → 放行
    if (authStore.isAuthenticated) {
      return null;
    }

    // 未登录 → 重定向到登录页
    return loginPath;
  };
}

/// 未登录时禁止访问的便捷守卫。
///
/// 与 [createAuthGuard] 相同，但 publicPaths 默认为空（所有路径都需要登录）。
GoRouterRedirect createStrictAuthGuard({required String loginPath}) {
  return createAuthGuard(loginPath: loginPath, publicPaths: const <String>[]);
}
