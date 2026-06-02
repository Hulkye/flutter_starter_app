import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/app_bootstrap.dart';
import '../core/exception/app_exception_catcher.dart';
import 'app.dart';
import 'env.dart';

class Application {
  /// 运行应用。
  ///
  /// ## 启动流程
  ///
  /// ```
  /// 1. appConfig = envConfig                        ← 全局配置
  /// 2. AppBootstrap.create(envConfig)                ← DI 引导
  ///    ├── prefsStorage.init()                     ← 存储
  ///    ├── secureStorage.init()                     ← 安全存储
  ///    ├── AuthSessionStore.restore()               ← 会话恢复
  ///    ├── AppRouter.initRouter()                   ← 路由注册
  ///    └── createEnvOverrides(env)                  ← Override 收集
  /// 3. AppExceptionCatcher.runAppGuarded            ← 异常兜底
  /// 4. ProviderScope(overrides: overrides)          ← 注入覆盖
  /// 5. App()                                        ← MaterialApp.router
  /// ```
  static Future<void> run({required EnvConfig envConfig}) async {
    // 设置全局环境配置 —— Provider 创建之前必须可用
    appConfig = envConfig;

    // 启动应用
    await AppExceptionCatcher.runAppGuarded(
      appRunner: () async {
        // DI 引导：异步初始化 + 环境 Override 收集
        final bootstrap = await AppBootstrap.create(envConfig);
        runApp(
          ProviderScope(overrides: bootstrap.overrides, child: const App()),
        );
      },
    );
  }
}
