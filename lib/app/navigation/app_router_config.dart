import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feature/app_feature_registry.dart';
import '../../core/router/router.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../shared/services/auth/auth.dart';
import '../../shared/webview/webview.dart';
import '../host/app_bootstrap_coordinator.dart';
import 'shell/root_shell_route.dart';
import 'splash/splash_route.dart';

/// 构建 App 的完整路由配置。
///
/// 应用层负责组合 Splash、Root Shell 和业务 Feature 路由；
/// core/router 只消费 [AppRouterConfig]，不直接依赖具体 Feature。
AppRouterConfig createAppRouterConfig(AppFeatureRegistry featureRegistry) {
  return AppRouterConfig(
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
  );
}

/// App 路由配置的 Provider 覆盖项。
List<Override> createAppRouterOverrides(AppFeatureRegistry featureRegistry) {
  return <Override>[
    appRouterConfigProvider.overrideWith(
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
        ...featureRegistry.guards,
        _AuthenticationRouteGuard(authenticated: authenticated),
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
