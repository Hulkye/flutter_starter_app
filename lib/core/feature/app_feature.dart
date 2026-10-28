import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_starter_app/core/router/router.dart';

import 'app_tab_entry.dart';
import 'app_feature_metadata.dart';
import 'app_external_route.dart';
import 'app_route_policy.dart';

/// Feature 对 App 暴露能力的统一协议。
///
/// 当前用于集中注册 Feature 路由、Tab 入口和默认依赖装配；后续可按需扩展
/// 初始化、菜单、权限等模块级能力。
abstract class AppFeature {
  const AppFeature();

  /// Feature 的身份、排序和启用策略元数据。
  AppFeatureMetadata get metadata;

  /// Feature 标识的便捷访问。
  String get key => metadata.key;

  /// 模块下的路由
  List<AppPageRoute<dynamic>> get routes;

  /// 模块下的tab入口
  List<AppTabEntry> get tabs => const [];

  /// 模块允许由 App 外部入口打开的路由。
  List<AppExternalRoute> get externalRoutes => const [];

  /// 模块下路由的静态访问策略。
  List<AppRoutePolicy> get routePolicies => const [];

  /// 模块级路由访问规则。
  ///
  /// App 组合层会按 Feature 注册顺序汇聚这些 Guard。最终链顺序为：
  /// Bootstrap（最先短路）→ Authentication → Feature Guards。
  List<AppRouteGuard> get guards => const [];

  /// Feature 专属浅色主题扩展。
  List<Object> get lightThemeExtensions => const [];

  /// Feature 专属深色主题扩展。
  List<Object> get darkThemeExtensions => const [];

  /// Feature 可选的独立本地化 delegate。
  ///
  /// 默认为空，因此未启用独立 ARB 的 Feature 不增加任何运行时成本。
  List<LocalizationsDelegate<dynamic>> get localizationDelegates => const [];

  /// 模块默认 Provider 覆盖项。
  ///
  /// Feature 可在这里把 domain 层 binding provider 装配到默认 data 实现。
  /// App 组合层只负责汇聚这些 overrides 并注入根 [ProviderScope]。
  List<Override> get providerOverrides => const [];
}
