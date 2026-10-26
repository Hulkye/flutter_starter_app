import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../adapters/go_router/route_transform.dart';
import '../adapters/go_router/access_guard.dart';
import '../adapters/go_router/router_navigator.dart' as go_router;
import '../adapters/router_navigator.dart';
import '../definitions/router_definitions.dart';
import '../guards/route_access_decision.dart';
import '../guards/app_route_request.dart';
import '../navigation/base_navigator.dart';

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
    this.publicRoutePatterns = const <String>[],
    this.observers = const <NavigatorObserver>[],
    this.errorBuilder,
  });

  /// 完整应用路由节点。
  final List<AppRouteNode> routeNodes;

  /// GoRouter 初始 location。
  final String initialLocation;

  /// App 组合层根据 RoutePolicy 生成的匿名路由匹配模板。
  final List<String> publicRoutePatterns;

  /// App 组合层注入的 NavigatorObserver，例如 Toast。
  ///
  /// core/router 不绑定具体 UI 组件；未注入时使用空列表。
  final List<NavigatorObserver> observers;

  /// App 组合层可注入的路由错误页面构建器。
  final Widget Function(BuildContext context, AppRouteError error)?
  errorBuilder;
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

/// App 组合层注入的路由访问决策函数。
final routeAccessDecisionProvider =
    Provider<RouteAccessDecision Function(AppRouteRequest)>((ref) {
      throw StateError(
        'routeAccessDecisionProvider must be overridden by the app composition layer.',
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
  ref.listen<RouteAccessDecision Function(AppRouteRequest)>(
    routeAccessDecisionProvider,
    (_, _) {
      refreshNotifier.refresh();
    },
  );

  return GoRouter(
    navigatorKey: routerNavigatorKey,
    initialLocation: routerConfig.initialLocation,
    observers: routerConfig.observers,
    refreshListenable: refreshNotifier,
    redirect: createGoRouterAccessGuard(
      accessDecision: (request) =>
          ref.read(routeAccessDecisionProvider)(request),
      routeNodes: routerConfig.routeNodes,
      publicPaths: routerConfig.publicRoutePatterns,
    ),
    errorBuilder: (context, state) {
      final error = AppRouteError(
        location: state.uri.toString(),
        message: state.error?.toString() ?? 'Unknown routing error',
        exception: state.error,
      );
      return routerConfig.errorBuilder?.call(context, error) ??
          AppRouteErrorView(error: error);
    },
    routes: routerConfig.routeNodes.map(toRouteBase).toList(),
  );
});

/// 导航接口 Provider。
///
/// 业务层依赖此 Provider 执行导航，不直接引用 [GoRouter]。
final appRouterProvider = Provider<BaseNavigator>((ref) {
  return RouterNavigator(
    go_router.RouterNavigator(ref.watch(goRouterProvider)),
  );
});

final class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final class AppRouteErrorView extends StatelessWidget {
  const AppRouteErrorView({required this.error, super.key});

  final AppRouteError error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline),
            const SizedBox(height: 12),
            const Text('页面无法打开'),
            const SizedBox(height: 8),
            Text(error.location),
          ],
        ),
      ),
    );
  }
}
