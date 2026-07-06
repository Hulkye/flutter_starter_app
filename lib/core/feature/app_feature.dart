import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/router/router.dart';

import 'app_tab_entry.dart';

/// Feature 对 App 暴露能力的统一协议。
///
/// 当前用于集中注册 Feature 路由、Tab 入口和默认依赖装配；后续可按需扩展
/// 初始化、菜单、权限等模块级能力。
abstract class AppFeature {
  const AppFeature();

  /// Feature 标识，用于日志、调试、菜单、权限或埋点。
  String get name;

  /// 模块下的路由
  List<AppPageRoute> get routes;

  /// 模块下的tab入口
  List<AppTabEntry> get tabs => const [];

  /// 模块默认 Provider 覆盖项。
  ///
  /// Feature 可在这里把 domain 层 binding provider 装配到默认 data 实现。
  /// App 组合层只负责汇聚这些 overrides 并注入根 [ProviderScope]。
  List<Override> get providerOverrides => const [];
}
