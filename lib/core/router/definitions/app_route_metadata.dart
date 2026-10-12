/// 路由身份与匹配元数据。
final class AppRouteMetadata {
  const AppRouteMetadata({required this.key, required this.path});

  /// 应用内稳定路由 key。
  final String key;

  /// 路由匹配模板。
  final String path;
}
