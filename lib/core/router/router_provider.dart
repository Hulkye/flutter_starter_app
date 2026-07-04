import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/services/auth/auth.dart';
import '../../shared/widgets/toast/toast_util.dart';
import 'app_router_transfor.dart';
import 'base_navigator.dart';
import 'definitions/router_definitions.dart';
import 'router_guard.dart';
import 'router_navigator.dart';

// =============================================================================
// 路由配置 —— 由 App 组合层注入
// =============================================================================

/// GoRouter 所需的应用路由配置。
///
/// core/router 只消费这份配置，不直接 import app 或 features。
final class AppRouterConfig {
  const AppRouterConfig({
    required this.routeNodes,
    required this.initialLocation,
    required this.loginLocation,
  });

  /// 完整应用路由节点。
  final List<AppRouteNode> routeNodes;

  /// GoRouter 初始 location。
  final String initialLocation;

  /// 未登录访问受保护页面时跳转的登录页 location。
  final String loginLocation;
}

/// 应用路由配置 Provider。
///
/// 由 app 组合层通过 ProviderScope.overrides 注入，保持 core/router
/// 不依赖具体业务 Feature。
final appRouterConfigProvider = Provider<AppRouterConfig>((ref) {
  throw StateError(
    'appRouterConfigProvider must be overridden by the app composition layer.',
  );
});

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
  final routerConfig = ref.watch(appRouterConfigProvider);
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<AuthSession?>(authSessionProvider, (_, _) {
    refreshNotifier.refresh();
  });

  return GoRouter(
    navigatorKey: routerNavigatorKey,
    initialLocation: routerConfig.initialLocation,
    observers: [ToastUtil.navigatorObserver],
    refreshListenable: refreshNotifier,
    redirect: createAuthGuard(
      loginPath: routerConfig.loginLocation,
      isAuthenticated: () => ref.read(authSessionProvider)?.isValid == true,
      publicPaths: collectPublicRoutePatterns(routerConfig.routeNodes),
    ),
    routes: routerConfig.routeNodes.map(toRouteBase).toList(),
  );
});

List<String> collectPublicRoutePatterns(List<AppRouteNode> nodes) {
  final publicRoutePatterns = <String>[];
  for (final node in nodes) {
    if (node is AppPageRoute && node.public) {
      publicRoutePatterns.add(node.path);
      continue;
    }
    if (node is AppRedirectRoute && node.public) {
      publicRoutePatterns.add(node.path);
      continue;
    }
    if (node is AppShellRoute) {
      for (final branch in node.branches) {
        publicRoutePatterns.addAll(collectPublicRoutePatterns(branch.routes));
      }
    }
  }
  return publicRoutePatterns;
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
