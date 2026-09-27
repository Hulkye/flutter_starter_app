import 'package:app_deep_link/app_deep_link.dart';

import '../../core/feature/app_feature_registry.dart';
import '../../shared/webview/presentation/webview_routes.dart';

/// App 组合层声明允许由外部 URI 打开的路由。
///
/// 这里不把 Deep Link 开关放进 [AppPageRoute]，避免 core/router 感知某个
/// 可选外部集成；未来 Push、OAuth 等入口可以拥有各自的注册策略。
List<DeepLinkRoute> createExternalDeepLinkRoutes(
  AppFeatureRegistry featureRegistry,
) {
  return <DeepLinkRoute>[
    for (final externalRoute in featureRegistry.externalRoutes)
      DeepLinkRoute(
        key: externalRoute.key,
        path: externalRoute.route.path,
        requiresAuthentication: !externalRoute.route.public,
      ),
    const DeepLinkRoute(
      key: WebPageRoute.pathValue,
      path: WebPageRoute.pathValue,
      requiresAuthentication: false,
    ),
  ];
}
