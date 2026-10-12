import 'package:flutter/widgets.dart';

import 'app_route_node.dart';
import 'app_route_metadata.dart';
import 'app_route_state.dart';

/// 应用页面路由定义。
///
/// [AppPageRoute] 只描述路由注册信息和页面构建方式。
///
/// ## 使用
///
/// ```dart
/// // 路由注册（在 router_provider.dart 中集中管理）
/// final List<AppPageRoute<dynamic>> _allRoutes = [
///   HomeRoute(),
///   ProfileRoute(),
/// ];
/// ```
///
/// ## 自定义路由
///
/// ```dart
/// final class SettingsRoute extends AppPageRoute<void> {
///   const SettingsRoute();
///
///   @override String get path => '/settings';
///   @override void parse(AppRouteState state) {}
///   @override Widget buildPage(BuildContext context, void args) {
///     return const SettingsPage();
///   }
/// }
/// ```
abstract class AppPageRoute<TArgs> extends AppRouteNode {
  const AppPageRoute();

  /// 路由匹配模式，例如 `/profile/:userId`。
  String get path;

  /// 路由身份与匹配元数据。
  AppRouteMetadata get metadata => AppRouteMetadata(key: path, path: path);

  /// 将路由状态解析为当前页面的类型化参数。
  TArgs parse(AppRouteState state);

  /// 使用类型化参数构建页面。
  Widget buildPage(BuildContext context, TArgs args);
}
