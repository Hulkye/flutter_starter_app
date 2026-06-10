/// Riverpod-native DI 系统。
///
/// ## 设计理念
///
/// Riverpod 本身就是 DI 容器。Provider 声明依赖，ProviderScope 管理生命周期，
/// ref.watch 解析依赖图。本 package 不做额外封装，仅提供：
///
/// - [Application.bootstrap] — 启动引导（Pre-ProviderScope 初始化编排）
/// - [createEnvOverrides] — 环境 Provider 覆盖工厂（可插拔入口）
///
/// ## 架构
///
/// ```
/// Application.run(env)              ← 唯一入口
///   ├── Phase 1: 核心服务初始化
///   │     ├── prefsStorage.init()
///   │     ├── secureStorage.init()
///   │     └── AuthSessionStore.restore()
///   └── Phase 2: createEnvOverrides(env)
///         └── List<Override> → ProviderScope.overrides
///
/// 之后的一切由 Riverpod 接管：
///   httpConfigProvider → httpClientProvider → repository providers → view models
/// ```
///
/// ## 使用
///
/// ```dart
/// import 'core/di/di.dart';
///
/// final overrides = createEnvOverrides(envConfig);
/// runApp(ProviderScope(
///   overrides: overrides,
///   child: const App(),
/// ));
/// ```
library;

export 'di_overrides.dart';

// 核心 Provider
export '../network/http/http_provider.dart';

// Feature Provider（后续按 Feature 添加）
// export '../../features/home/di/home_providers.dart';
// export '../../features/auth/di/auth_providers.dart';
