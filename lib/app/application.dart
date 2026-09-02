import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/features/features.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_store.dart';

import '../core/exception/app_exception_catcher.dart';
import '../core/capability/app_capability.dart';
import '../core/router/router.dart';
import '../features/auth/presentation/auth_routes.dart';
import 'app.dart';
import 'capabilities/app_capability_registry.dart';
import 'navigation/app_router_config.dart';
import '../integrations/deep_link/deep_link_integration.dart';
import '../integrations/deep_link/deep_link_provider.dart';

class Application {
  static Future<void> bootstrap() async {
    // Pre-ProviderScope 初始化
    await prefsStorage.init();
    await secureStorage.init();
    await authStore.init();
  }

  /// 运行应用。
  static Future<void> run({required EnvConfig envConfig}) async {
    // 设置全局环境配置 —— Provider 创建之前必须可用
    appConfig = envConfig;

    // 启动应用
    await AppExceptionCatcher.runAppGuarded(
      appRunner: () async {
        WidgetsFlutterBinding.ensureInitialized();
        await bootstrap();
        final featureRegistry = createAppFeatureRegistry(envConfig.envTag);
        final overrides = <Override>[
          ...featureRegistry.providerOverrides,
          if (envConfig.deepLinkConfig != null)
            ...DeepLinkIntegration.createOverrides(
              featureRegistry,
              requestAuthentication: (ref) {
                final router = ref.read(appRouterProvider);
                final loginLocation = const LoginRoute().location;
                if (router.location != loginLocation) {
                  router.replaceAll(loginLocation);
                }
              },
            ),
          appCapabilityRegistryProvider.overrideWith(
            (ref) => AppCapabilityRegistry(
              capabilities: envConfig.deepLinkConfig == null
                  ? const <AppCapability>[]
                  : <AppCapability>[ref.read(deepLinkCapabilityProvider)],
            ),
          ),
          ...createAppRouterOverrides(featureRegistry),
        ];
        runApp(ProviderScope(overrides: overrides, child: const App()));
      },
    );
  }
}
