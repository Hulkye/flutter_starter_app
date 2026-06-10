import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/splash/splash_route.dart';
import '../../app/shell/root_shell_route.dart';
import '../../features/features.dart';
import '../../shared/services/auth/auth.dart';
import '../../shared/widgets/toast/toast_util.dart';
import 'app_router_transfor.dart';
import 'base_navigator.dart';
import 'definitions/router_definitions.dart';
import 'router_guard.dart';
import 'router_navigator.dart';

// =============================================================================
// 路由注册表 —— 由各 Feature 汇聚生成
// =============================================================================

/// 所有应用路由节点。
final List<AppRouteNode> _allRouteNodes = <AppRouteNode>[
  const SplashRoute(),
  ...buildRootRouteNodes(),
  ...appFeatureRoutes,
];

// =============================================================================
// Provider
// =============================================================================

/// 全局 Navigator Key，供非 Widget 上下文（如 Controller）导航。
final GlobalKey<NavigatorState> routerNavigatorKey =
    GlobalKey<NavigatorState>();

/// GoRouter 实例 Provider。
///
/// 登录态变化时只刷新 redirect，不重建 Router，避免重新应用 initialLocation。
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<AuthSession?>(authSessionProvider, (_, _) {
    refreshNotifier.refresh();
  });

  return GoRouter(
    navigatorKey: routerNavigatorKey,
    initialLocation: const SplashRoute().location,
    observers: [ToastUtil.navigatorObserver],
    refreshListenable: refreshNotifier,
    redirect: createAuthGuard(
      loginPath: const LoginRoute().location,
      publicPaths: collectPublicPaths(_allRouteNodes),
    ),
    routes: _allRouteNodes.map(toRouteBase).toList(),
  );
});

List<String> collectPublicPaths(List<AppRouteNode> nodes) {
  final publicPaths = <String>[];
  for (final node in nodes) {
    if (node is AppPageRoute && node.public) {
      publicPaths.add(node.path);
      continue;
    }
    if (node is AppRedirectRoute && node.public) {
      publicPaths.add(node.path);
      continue;
    }
    if (node is AppShellRoute) {
      for (final branch in node.branches) {
        publicPaths.addAll(collectPublicPaths(branch.routes));
      }
    }
  }
  return publicPaths;
}

/// 导航接口 Provider。
///
/// 业务层依赖此 Provider 执行导航，不直接引用 [GoRouter]。
final appRouterProvider = Provider<BaseNavigator>((ref) {
  return RouterNavigator(ref.watch(goRouterProvider));
});

final class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
