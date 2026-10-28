import 'package:flutter/widgets.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth.dart';

import '../core/exception/app_exception_catcher.dart';
import 'app_startup.dart';

class Application {
  /// 解析入口传入的环境配置及其可选运行时配置。
  static const _environmentResolver = AppEnvironmentResolver();

  /// 根据当前环境组合可用的业务 Feature 注册表。
  static const _featureComposer = AppFeatureComposer();

  /// 汇聚 Feature、Capability、App 服务和路由所需的 Provider overrides。
  static const _providerComposer = AppProviderComposer();

  /// 使用完成装配的 overrides 挂载 Flutter 根组件。
  static const _runtime = AppRuntime();

  /// 在根 ProviderScope 创建前初始化全局存储和登录会话。
  ///
  /// 这些对象会被后续 Provider 和 AppHost 读取，因此必须在 [run] 挂载
  /// Widget 树前完成。
  static Future<void> bootstrap() async {
    await prefsStorage.init();
    await secureStorage.init();
    await authStore.init();
  }

  /// 执行受异常保护的 App 启动流程。
  ///
  /// 启动顺序固定为：Flutter binding、环境解析、全局存储初始化、Feature
  /// 注册、Provider 装配，最后交给 AppRuntime 挂载 Widget 树。
  static Future<void> run({required EnvConfig envConfig}) async {
    await AppExceptionCatcher.runAppGuarded(
      appRunner: () async {
        WidgetsFlutterBinding.ensureInitialized();
        final resolvedConfig = await _environmentResolver.resolve(envConfig);
        // 配置必须在 Provider 创建前写入，并且位于异常捕获 Zone 内。
        appConfig = resolvedConfig;
        await bootstrap();
        final featureRegistry = _featureComposer.compose(resolvedConfig.envTag);
        final overrides = _providerComposer.compose(
          resolvedConfig,
          featureRegistry,
        );
        _runtime.run(overrides);
      },
    );
  }
}
