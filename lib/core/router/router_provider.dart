import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/features.dart';
import '../../shared/services/auth/auth.dart';
import '../../shared/widgets/toast/toast_util.dart';
import 'app_route_define.dart';
import 'app_router_transfor.dart';
import 'base_navigator.dart';
import 'router_guard.dart';
import 'router_navigator.dart';

// =============================================================================
// 路由注册表 —— 由各 Feature 汇聚生成
// =============================================================================

/// 所有 Feature 的路由定义。
final List<AppRouteDefine> _allRoutes = appFeatureRoutes;

// =============================================================================
// Provider
// =============================================================================

/// 全局 Navigator Key，供非 Widget 上下文（如 Controller）导航。
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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
    navigatorKey: rootNavigatorKey,
    initialLocation: const HomeRoute().location,
    observers: [ToastUtil.navigatorObserver],
    refreshListenable: refreshNotifier,
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

final class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
