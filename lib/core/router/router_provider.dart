import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_routes.dart';
import '../../features/home/presentation/home_routes.dart';
import '../../features/profile/presentation/profile_routes.dart';
import '../../features/todo/presentation/todo_routes.dart';
import '../../shared/services/auth/auth.dart';
import '../../shared/widgets/toast/toast_util.dart';
import 'app_route_define.dart';
import 'app_router_transfor.dart';
import 'base_navigator.dart';
import 'router_guard.dart';
import 'router_navigator.dart';

// =============================================================================
// 路由注册表 —— 新增 Feature 时在这里添加一行
// =============================================================================

/// 所有 Feature 的路由定义集中注册。
///
/// 新增路由步骤：
/// 1. 创建 `XxxRoute extends AppRouteDefine`
/// 2. 在此列表中添加 `XxxRoute()`
final List<AppRouteDefine> _allRoutes = [
  HomeRoute(),
  ProfileRoute(),
  LoginRoute(),
  TodoRoute(),
];

// =============================================================================
// Provider
// =============================================================================

/// 全局 Navigator Key，供非 Widget 上下文（如 Controller）导航。
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter 实例 Provider。
///
/// 依赖 [authSessionProvider] —— 登录态变化时自动重新评估 redirect。
final goRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(authSessionProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: const HomeRoute().location,
    observers: [ToastUtil.navigatorObserver],
    redirect: createAuthGuard(
      loginPath: const LoginRoute().location,
      publicPaths: _allRoutes
          .where((route) => route.public)
          .map((route) => route.path)
          .toList(),
    ),
    routes: _allRoutes.map(toGoRoute).toList(),
  );
});

/// 导航接口 Provider。
///
/// 业务层依赖此 Provider 执行导航，不直接引用 [GoRouter]。
final appRouterProvider = Provider<BaseNavigator>((ref) {
  return RouterNavigator(ref.watch(goRouterProvider));
});
