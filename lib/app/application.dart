import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/di/di.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_store.dart';

import '../core/exception/app_exception_catcher.dart';
import 'app.dart';
import 'di/app_feature_provider_overrides.dart';
import 'env.dart';
import 'router/app_router_config.dart';

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
        final overrides = [
          ...createAppFeatureProviderOverrides(),
          ...createEnvOverrides(envConfig),
          ...createAppRouterOverrides(),
        ];
        runApp(ProviderScope(overrides: overrides, child: const App()));
      },
    );
  }
}
