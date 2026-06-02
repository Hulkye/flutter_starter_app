import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/env.dart';

/// 根据环境生成 Provider Override 列表 —— 可插拔核心。
///
/// 这是整个 DI 系统唯一的"可变"点。返回的 [Override] 列表注入
/// [ProviderScope.overrides]，实现在不同环境/场景下替换 Provider 实现。
///
/// ## 为什么用纯函数而不是 Module 类
///
/// | 方式          | 代码量 | 编译安全 | 可读性 |
/// |--------------|-------|---------|-------|
/// | Module 类      | 多     | 否      | 差    |
/// | 纯函数 + Override | 少     | 是      | 好    |
///
/// 一个函数，所有可覆盖的 Provider 一目了然。新增覆盖只需在列表中添加一项。
///
/// ## 常见覆盖场景
///
/// ```dart
/// // 环境 Mock
/// if (env.isDev) homeRepositoryProvider.overrideWith((ref) => MockHomeRepo());
///
/// // Feature Flag
/// if (featureFlags.useNewApi) apiProvider.overrideWith((ref) => NewApi());
///
/// // A/B 测试
/// if (abTest.inGroupB) checkoutProvider.overrideWith((ref) => CheckoutB());
/// ```
///
/// ## 新增覆盖
///
/// 1. 在下方列表中添加对应的 `.overrideWith(...)` 项
/// 2. 按环境条件包裹（`if (env.tag == EnvTag.dev)`）
/// 3. 测试中直接构造 `createEnvOverrides` 返回结果亦可覆盖
List<Override> createEnvOverrides(EnvConfig env) {
  return <Override>[
    // ===============================================
    // 👇 在此添加环境专属的 Provider 覆盖
    // ===============================================

    // 示例：Dev 环境用 Mock Repository 替换真实实现
    // if (env.envTag == EnvTag.dev)
    //   homeRepositoryProvider.overrideWith(
    //     (ref) => MockHomeRepository(),
    //   ),

    // 示例：SIT 环境使用独立的 API 域名
    // if (env.envTag == EnvTag.sit)
    //   httpConfigProvider.overrideWith(
    //     (ref) => HttpConfig(baseUrl: env.apiBaseUrl, ...),
    //   ),
  ];
}
