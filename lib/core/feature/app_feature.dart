import 'package:flutter_starter_app/core/router/router.dart';
import 'app_tab_entry.dart';

/// Feature 对 App 暴露能力的统一协议。
///
/// 当前主要用于集中注册 Feature 路由；后续可按需扩展初始化、菜单、权限、
/// Provider overrides 等模块级能力。
abstract class AppFeature {
  const AppFeature();

  /// Feature 标识，用于日志、调试、菜单、权限或埋点。
  String get name;

  /// 模块下的路由
  List<AppPageRoute> get routes;

  /// 模块下的tab入口
  List<AppTabEntry> get tabs => const [];
}
