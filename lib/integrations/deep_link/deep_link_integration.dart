import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/capability/app_capability.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_feature_registry.dart';

import 'application/deep_link_coordinator.dart';
import 'application/deep_link_resolver.dart';
import 'domain/deep_link_route_registry.dart';

/// Deep Link 可选集成的 App 装配入口。
final class DeepLinkIntegration {
  const DeepLinkIntegration._();

  /// 创建 Deep Link 能力及其 Provider 覆盖项。
  static List<Override> createOverrides(
    AppFeatureRegistry featureRegistry, {
    required void Function(Ref ref) requestAuthentication,
  }) {
    return createDeepLinkOverrides(
      featureRegistry,
      requestAuthentication: requestAuthentication,
    );
  }

  /// 创建不依赖 Riverpod 的 Deep Link 能力实例。
  static DeepLinkCapability createCapability({
    required ProviderListenableReader read,
    required EnvConfig config,
    required DeepLinkRouteRegistry routeRegistry,
    required void Function() requestAuthentication,
  }) {
    return DeepLinkCoordinator(
      read: read,
      requestAuthentication: requestAuthentication,
      resolver: DeepLinkResolver(config: config, routes: routeRegistry.routes),
    );
  }
}
