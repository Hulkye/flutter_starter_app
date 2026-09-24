import 'package:flutter/widgets.dart';

import 'app_route_node.dart';
import 'app_route_state.dart';

/// 应用页面路由定义。
///
/// [AppPageRoute] 描述路由注册信息，也可以作为类型安全的 location helper。
/// 真正的导航接口接收 location 字符串，方便深链入口直接复用同一套协议。
///
/// ## 使用
///
/// ```dart
/// // 导航
/// ref.read(appRouterProvider).push(const ProfileRoute().location);
/// ref.read(appRouterProvider).go('/profile/42?tab=posts');
///
/// // 路由注册（在 router_provider.dart 中集中管理）
/// final List<AppPageRoute> _allRoutes = [
///   HomeRoute(),
///   ProfileRoute(),
/// ];
/// ```
///
/// ## 自定义路由
///
/// ```dart
/// final class SettingsRoute extends AppPageRoute {
///   const SettingsRoute();
///
///   @override String get path => '/settings';
///   @override Widget buildPage(BuildContext context, AppRouteState state) {
///     return const SettingsPage();
///   }
/// }
/// ```
abstract class AppPageRoute extends AppRouteNode {
  const AppPageRoute();

  /// 路由匹配模式，例如 `/profile/:userId`。
  String get path;

  /// 实际跳转 location，默认与 [path] 相同。
  ///
  /// 当路由包含动态参数时，子类应覆盖此方法：
  /// ```dart
  /// @override String get location => '/profile/$userId';
  /// ```
  String get location => path;

  /// 是否无需登录即可访问，默认 false。
  @override
  bool get public => false;

  /// 构建页面。
  ///
  /// [state] 包含 path 参数、query 参数等信息，类型为 [AppRouteState]（不依赖 GoRouterState）。
  Widget buildPage(BuildContext context, AppRouteState state);
}
