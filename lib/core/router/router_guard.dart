import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/services/auth/auth_manager.dart';

/// 创建认证路由守卫。
///
/// 返回的函数直接传给 [GoRouter.redirect]。
///
/// [publicPaths] 中的路径无需登录即可访问，默认只放行主页 `/`。
GoRouterRedirect createAuthGuard({
  required String loginPath,
  List<String> publicPaths = const <String>['/'],
}) {
  return (BuildContext context, GoRouterState state) {
    final currentPath = state.uri.path;

    // 公开路径 → 放行
    if (publicPaths.contains(currentPath)) {
      return null;
    }

    // 已登录 → 放行
    if (authManager.isAuthenticated) {
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
