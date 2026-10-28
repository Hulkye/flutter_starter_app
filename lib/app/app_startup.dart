import 'package:app_deep_link/app_deep_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/capability/app_capability.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_feature_registry.dart';
import 'package:flutter_starter_app/core/network/http/http.dart';
import 'package:flutter_starter_app/core/router/export.dart';
import 'package:flutter_starter_app/features/auth/presentation/auth_routes.dart';
import 'package:flutter_starter_app/features/features.dart';
import 'package:flutter_starter_app/integrations/deep_link_host/deep_link_app_capability.dart';
import 'package:flutter_starter_app/shared/services/auth/auth.dart';

import 'app.dart';
import 'capabilities/app_capability_registry.dart';
import 'navigation/app_router_config.dart';
import 'navigation/pending_navigation_coordinator.dart';
import 'providers/localization_delegates_provider.dart';
import 'providers/theme_extensions_provider.dart';

/// 解析启动环境，并加载环境对应的可选配置。
///
/// 该阶段只负责把外部传入的 [EnvConfig] 转换为运行时配置，不负责初始化
/// 存储、注册 Feature 或创建 Provider。
final class AppEnvironmentResolver {
  const AppEnvironmentResolver();

  /// 加载当前环境的 Deep Link 配置并返回解析后的配置。
  Future<EnvConfig> resolve(EnvConfig config) async {
    final deepLinkConfig = await tryLoadDeepLinkConfig(
      environment: config.envTag.name,
    );
    return config.copyWith(deepLinkConfig: deepLinkConfig);
  }
}

/// 将当前环境允许启用的业务 Feature 组合为唯一注册表。
///
/// Feature 的路由、Tab、Provider overrides 和主题/本地化贡献都由注册表统一
/// 派生，后续阶段不应重新读取候选 Feature 列表。
final class AppFeatureComposer {
  const AppFeatureComposer();

  /// 构建指定 [environment] 下的 Feature 注册结果。
  AppFeatureRegistry compose(EnvTag environment) {
    return createAppFeatureRegistry(environment);
  }
}

/// 根据运行时配置装配 App 级可选能力及其生命周期注册表。
///
/// 能力未在环境配置中启用时，不创建对应的 override，也不注册生命周期实例，
/// 从而避免启动平台监听或创建不需要的外部资源。
final class AppCapabilityComposer {
  const AppCapabilityComposer();

  /// 返回当前环境中已启用能力所需的 Provider overrides。
  List<Override> composeOverrides(
    EnvConfig config,
    AppFeatureRegistry featureRegistry,
  ) {
    if (config.deepLinkConfig == null) return const <Override>[];
    return createDeepLinkAppOverrides(featureRegistry);
  }

  /// 创建统一管理能力生命周期的注册表 Provider override。
  Override composeRegistryOverride(EnvConfig config) {
    return appCapabilityRegistryProvider.overrideWith(
      (ref) => AppCapabilityRegistry(
        capabilities: config.deepLinkConfig == null
            ? const <AppCapability>[]
            : <AppCapability>[ref.read(deepLinkAppCapabilityProvider)],
      ),
    );
  }
}

/// 汇聚根 [ProviderScope] 使用的全部 Provider overrides。
///
/// 该阶段只负责依赖装配，不读取业务状态，也不启动 Widget 树；override 的
/// 顺序表达了 Feature 依赖、通用 App 适配、可选能力和路由配置的组合关系。
final class AppProviderComposer {
  const AppProviderComposer({
    this.capabilityComposer = const AppCapabilityComposer(),
  });

  final AppCapabilityComposer capabilityComposer;

  /// 按 App 约定的顺序组合当前环境的全部 overrides。
  List<Override> compose(EnvConfig config, AppFeatureRegistry featureRegistry) {
    return <Override>[
      ...featureRegistry.providerOverrides,
      appLightThemeExtensionsProvider.overrideWithValue(
        featureRegistry.lightThemeExtensions,
      ),
      appDarkThemeExtensionsProvider.overrideWithValue(
        featureRegistry.darkThemeExtensions,
      ),
      appLocalizationDelegatesProvider.overrideWithValue(
        featureRegistry.localizationDelegates,
      ),
      _createHttpAuthSessionOverride(),
      _createPendingNavigationOverride(),
      ...capabilityComposer.composeOverrides(config, featureRegistry),
      capabilityComposer.composeRegistryOverride(config),
      ...createAppRouterOverrides(featureRegistry),
    ];
  }

  Override _createHttpAuthSessionOverride() {
    return httpAuthSessionAccessProvider.overrideWith(
      (ref) => _AppHttpAuthSessionAccess(ref),
    );
  }

  Override _createPendingNavigationOverride() {
    return createPendingNavigationOverride(
      requestAuthentication: (ref) {
        final router = ref.read(appRouterProvider);
        const loginTarget = LoginTarget();
        if (router.location != loginTarget.location) {
          router.replaceAll(loginTarget);
        }
      },
    );
  }
}

/// 将已完成的依赖装配交给 Flutter 运行时。
///
/// Runtime 不参与环境解析或依赖选择，只负责创建根 [ProviderScope] 并挂载
/// [App]，使启动阶段和 Widget 生命周期保持边界清晰。
final class AppRuntime {
  const AppRuntime();

  /// 使用 [overrides] 挂载应用根组件。
  void run(List<Override> overrides) {
    runApp(ProviderScope(overrides: overrides, child: const App()));
  }
}

final class _AppHttpAuthSessionAccess implements HttpAuthSessionAccess {
  const _AppHttpAuthSessionAccess(this._ref);

  final Ref _ref;

  @override
  String? get authorization {
    final session = _ref.read(authSessionProvider);
    return session?.isValid == true ? session!.bearerToken : null;
  }

  @override
  Future<void> clearSession() {
    return _ref.read(authSessionControllerProvider).clearSession();
  }
}
