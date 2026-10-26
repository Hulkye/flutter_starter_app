import 'app_route_target.dart';

/// 将已解析的 path/query 参数编码为一次导航目标。
///
/// 该解析器只负责 URL 编码，不负责路由存在性、权限或认证判断。
final class AppRouteTargetResolver {
  const AppRouteTargetResolver();

  /// 创建包含 path 参数、query 参数和进程内附加数据的目标。
  AppRouteTarget resolve({
    required String path,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) {
    final resolvedPath = AppRouteLocation.withPathParameters(
      path,
      pathParameters,
    );

    final location = queryParameters.isEmpty
        ? resolvedPath
        : Uri(path: resolvedPath, queryParameters: queryParameters).toString();

    return AppRouteTargetValue(location: location, extra: extra);
  }
}
