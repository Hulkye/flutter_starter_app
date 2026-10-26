import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feature/app_feature_registry.dart';
import '../../core/router/router.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../shared/services/auth/auth.dart';
import '../../shared/webview/webview.dart';
import '../../shared/widgets/toast/toast_util.dart';
import '../host/app_bootstrap_coordinator.dart';
import 'shell/root_shell_route.dart';
import 'splash/splash_route.dart';

/// 构建框架无关的 App 路由定义，不绑定具体 Router runtime。
///
/// 应用层负责组合 Splash、Root Shell 和业务 Feature 路由；
/// core/router runtime 接收该定义，不直接依赖具体 Feature。
AppRouterDefinition createAppRouterConfig(AppFeatureRegistry featureRegistry) {
  return AppRouterDefinition(
    routeNodes: <AppRouteNode>[
      const SplashRoute(),
      ...buildRootRouteNodes(tabs: featureRegistry.tabs),
      ...featureRegistry.routes,
      const WebPageRoute(),
      const AuthWebPageRoute(),
    ],
    initialLocation: const SplashTarget().location,
    publicRoutePatterns: <String>[
      ...featureRegistry.publicRoutePatterns,
      const SplashRoute().path,
      WebPageRoute.pathValue,
    ],
    observers: <NavigatorObserver>[ToastUtil.navigatorObserver],
  );
}

/// App 路由配置的 Provider 覆盖项。
List<Override> createAppRouterOverrides(AppFeatureRegistry featureRegistry) {
  return <Override>[
    ...createRouterRuntimeOverrides(),
    appRouterDefinitionProvider.overrideWith(
      (ref) => createAppRouterConfig(featureRegistry),
    ),
    routeAccessDecisionProvider.overrideWith((ref) {
      if (!ref.watch(appBootstrapCompletedProvider)) {
        return (AppRouteRequest request) => RedirectRoute(
          target: const SplashTarget(),
          appliesToPublicRoutes: true,
        );
      }

      final authenticated = ref.watch(authSessionProvider)?.isValid == true;
      final guardChain = AppRouteGuardChain([
        _AuthenticationRouteGuard(authenticated: authenticated),
        ...featureRegistry.guards,
      ]);
      return guardChain.evaluate;
    }),
  ];
}

final class _AuthenticationRouteGuard implements AppRouteGuard {
  const _AuthenticationRouteGuard({required this.authenticated});

  final bool authenticated;

  @override
  RouteAccessDecision evaluate(AppRouteRequest request) {
    if (authenticated) {
      return AllowRoute(
        redirects: <String, AppRouteTarget>{
          const LoginTarget().location: const RootTarget(),
        },
      );
    }
    return const RedirectRoute(target: LoginTarget(), preserveTarget: true);
  }
}
