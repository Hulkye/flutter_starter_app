/// 框架无关的路由状态。
///
/// 由 [toAppRouteState] 从 GoRouterState 转换而来，避免 Feature 路由定义直接依赖 GoRouterState。
class AppRouteState {
  const AppRouteState({
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
