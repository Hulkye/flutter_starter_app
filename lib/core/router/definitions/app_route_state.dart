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

  /// 读取可选的 path 参数。
  String? pathParameter(String name) => pathParameters[name];

  /// 读取必需的 path 参数；缺失时显式报告非法路由状态。
  String requiredPathParameter(String name) {
    final value = pathParameters[name];
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required path parameter: $name');
    }
    return value;
  }

  /// 读取可选的 query 参数。
  String? queryParameter(String name) => queryParameters[name];

  /// 读取必需的 query 参数；缺失时显式报告非法路由状态。
  String requiredQueryParameter(String name) {
    final value = queryParameters[name];
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required query parameter: $name');
    }
    return value;
  }
}
