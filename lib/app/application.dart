import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_deep_link/app_deep_link.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/features/features.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_store.dart';

import '../core/exception/app_exception_catcher.dart';
import '../core/capability/app_capability.dart';
import '../core/feature/app_feature_registry.dart';
import '../core/router/router.dart';
import '../features/auth/presentation/auth_routes.dart';
import '../integrations/deep_link_host/deep_link_app_capability.dart';
import 'app.dart';
import 'capabilities/app_capability_registry.dart';
import 'navigation/app_router_config.dart';
import 'navigation/pending_navigation_coordinator.dart';

class Application {
  static Future<void> bootstrap() async {
    // Pre-ProviderScope 初始化
    await prefsStorage.init();
    await secureStorage.init();
    await authStore.init();
  }

  /// 运行应用。
  static Future<void> run({required EnvConfig envConfig}) async {
    // 启动应用
    await AppExceptionCatcher.runAppGuarded(
      appRunner: () async {
        WidgetsFlutterBinding.ensureInitialized();
        final resolvedConfig = await _createResolvedConfig(envConfig);
        // 配置在 binding 初始化和异常捕获 Zone 内完成，供 Provider 创建使用。
        appConfig = resolvedConfig;
        await bootstrap();
        final featureRegistry = createAppFeatureRegistry(resolvedConfig.envTag);
        final overrides = _createProviderOverrides(
          resolvedConfig,
          featureRegistry,
        );
        runApp(ProviderScope(overrides: overrides, child: const App()));
      },
    );
  }

  /// 生成处理后的EnvConfig
  static Future<EnvConfig> _createResolvedConfig(EnvConfig envConfig) async {
    final deepLinkConfig = await tryLoadDeepLinkConfig(
      environment: envConfig.envTag.name,
    );
    return envConfig.copyWith(deepLinkConfig: deepLinkConfig);
  }

  /// 组装 ProviderScope 所需的全部 overrides。
  ///
  /// 装配顺序保持为：Feature 依赖、待处理导航、可选能力、能力生命周期
  /// 注册表和 App 路由。具体能力的创建细节由对应的私有方法负责。
  static List<Override> _createProviderOverrides(
    EnvConfig envConfig,
    AppFeatureRegistry featureRegistry,
  ) {
    return <Override>[
      ...featureRegistry.providerOverrides,
      _createPendingNavigationOverride(),
      ..._createOptionalCapabilityOverrides(envConfig),
      _createCapabilityRegistryOverride(envConfig),
      ...createAppRouterOverrides(featureRegistry),
    ];
  }

  /// 注入认证失败时的统一登录跳转策略。
  ///
  /// 待处理导航协调器只负责判断何时需要认证，不直接决定登录页位置，
  /// 具体目标由 App 组合层提供。
  static Override _createPendingNavigationOverride() {
    return createPendingNavigationOverride(
      requestAuthentication: (ref) {
        final router = ref.read(appRouterProvider);
        final loginLocation = const LoginRoute().location;
        if (router.location != loginLocation) {
          router.replaceAll(loginLocation);
        }
      },
    );
  }

  /// 创建当前环境启用的可选能力 overrides。
  ///
  /// Deep Link 配置不存在时返回空列表，确保不会创建解析 engine 或订阅
  /// 平台 URI；其他可选能力可以在这里按同样方式扩展。
  static List<Override> _createOptionalCapabilityOverrides(
    EnvConfig envConfig,
  ) {
    // Deep Link 未配置时，不创建 engine，也不开始平台 URI 监听。
    if (envConfig.deepLinkConfig == null) return const <Override>[];
    return createDeepLinkAppOverrides();
  }

  /// 注册当前环境已启用的 App 能力生命周期实例。
  ///
  /// 注册表只管理能力的启动、生命周期通知和释放，不包含 Deep Link 的
  /// 业务判断；是否加入 Deep Link capability 由环境配置决定。
  static Override _createCapabilityRegistryOverride(EnvConfig envConfig) {
    return appCapabilityRegistryProvider.overrideWith(
      (ref) => AppCapabilityRegistry(
        capabilities: envConfig.deepLinkConfig == null
            ? const <AppCapability>[]
            : <AppCapability>[ref.read(deepLinkAppCapabilityProvider)],
      ),
    );
  }
}
