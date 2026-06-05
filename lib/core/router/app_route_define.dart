import 'package:flutter/widgets.dart';

// =============================================================================
// 路由状态
// =============================================================================

/// 框架无关的路由状态。
///
/// 由 [toGoRoute] 从 GoRouterState 转换而来，避免 Feature 路由定义直接依赖 GoRouterState。
class RouteState {
  const RouteState({
    required this.location,
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
    this.extra,
  });

  /// 完整 location，例如 `/profile/42?tab=posts`。
  final String location;

  /// Path 参数，例如 `/profile/:userId` 中的 `userId`。
  final Map<String, String> pathParameters;

  /// Query 参数，例如 `?tab=posts`。
  final Map<String, String> queryParameters;

  /// 路由附加参数。
  final Object? extra;
}

// =============================================================================
// 路由定义 —— 导航目标 + 注册描述，统一为一个对象
// =============================================================================

/// 应用路由定义。
///
/// [AppRouteDefine] 描述路由注册信息，也可以作为类型安全的 location helper。
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
/// final List<AppRouteDefine> _allRoutes = [
///   HomeRoute(),
///   ProfileRoute(),
/// ];
/// ```
///
/// ## 自定义路由
///
/// ```dart
/// final class SettingsRoute extends AppRouteDefine {
///   const SettingsRoute();
///
///   @override String get path => '/settings';
///   @override Widget buildPage(BuildContext context, RouteState state) {
///     return const SettingsPage();
///   }
/// }
/// ```
abstract class AppRouteDefine {
  const AppRouteDefine();

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
  bool get public => false;

  /// 构建页面。
  ///
  /// [state] 包含 path 参数、query 参数等信息，类型为 [RouteState]（不依赖 GoRouterState）。
  Widget buildPage(BuildContext context, RouteState state);
}
