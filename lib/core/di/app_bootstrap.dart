import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/env.dart';
import '../../shared/services/auth/auth_store.dart';
import '../storage/storage_provider.dart';
import 'di_overrides.dart';

/// 应用启动引导 —— DI 系统唯一入口。
///
/// ## 职责
///
/// 1. **Pre-ProviderScope 初始化**：存储、AuthSession 等必须在 ProviderScope 之前就绪
/// 2. **收集环境 Override**：调用 [createEnvOverrides] 生成 [ProviderScope.overrides]
///
/// ## 生命周期
///
/// ```
/// main()
///   → appConfig = envConfig
///   → AppBootstrap.create(envConfig)
///     → prefsStorage.init()        // SharedPreferences
///     → secureStorage.init()       // FlutterSecureStorage
///     → AuthSessionStore.restore() // 会话恢复
///     → createEnvOverrides(env)    // 覆盖收集
///   → runApp(ProviderScope(
///       overrides: bootstrap.overrides,
///       child: App(),
///     ))
/// ```
class AppBootstrap {
  final List<Override> overrides;

  const AppBootstrap._(this.overrides);

  static Future<AppBootstrap> create(EnvConfig env) async {
    WidgetsFlutterBinding.ensureInitialized();

    // ── Phase 1: Pre-ProviderScope 异步初始化 ──

    // 1. 存储引擎 —— 最先初始化，其他服务可能依赖
    await prefsStorage.init();
    await secureStorage.init();

    // 2. 登录会话恢复 —— 从安全存储恢复 token
    await authStore.init();

    // ── Phase 2: 收集环境 Override ──
    final overrides = createEnvOverrides(env);

    return AppBootstrap._(overrides);
  }
}
