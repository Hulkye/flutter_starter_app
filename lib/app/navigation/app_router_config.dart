import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/router.dart';
import '../../features/auth/presentation/auth_routes.dart';
import '../../features/features.dart';
import '../../shared/services/auth/auth.dart';
import '../../shared/webview/webview.dart';
import '../host/app_bootstrap_coordinator.dart';
import 'shell/root_shell_route.dart';
import 'splash/splash_route.dart';

/// 构建 App 的完整路由配置。
///
/// 应用层负责组合 Splash、Root Shell 和业务 Feature 路由；
/// core/router 只消费 [AppRouterConfig]，不直接依赖具体 Feature。
AppRouterConfig createAppRouterConfig() {
  return AppRouterConfig(
    routeNodes: <AppRouteNode>[
      const SplashRoute(),
      ...buildRootRouteNodes(),
      ...appFeatureRoutes,
      const WebPageRoute(),
      const AuthWebPageRoute(),
    ],
    initialLocation: const SplashRoute().location,
  );
}

/// App 路由配置的 Provider 覆盖项。
List<Override> createAppRouterOverrides() {
  return <Override>[
    appRouterConfigProvider.overrideWith((ref) => createAppRouterConfig()),
    routeAccessDecisionProvider.overrideWith((ref) {
      if (!ref.watch(appBootstrapCompletedProvider)) {
        return RedirectRoute(
          location: SplashRoute().location,
          appliesToPublicRoutes: true,
        );
      }

      final authenticated = ref.watch(authSessionProvider)?.isValid == true;
      if (authenticated) {
        return AllowRoute(
          redirects: <String, String>{
            const LoginRoute().location: RootRoute.location,
          },
        );
      }
      return RedirectRoute(
        location: const LoginRoute().location,
        preserveTarget: true,
      );
    }),
  ];
}
