/// 宿主 App 暴露给 Deep Link package 的最小路由描述。
///
/// package 不依赖宿主的页面路由类型，只使用这份稳定的数据契约完成
/// path 匹配和认证要求传递。
final class DeepLinkRoute {
  const DeepLinkRoute({
    required this.key,
    required this.path,
    required this.requiresAuthentication,
  });

  /// 宿主侧用于识别该路由的稳定 key。
  final String key;

  /// 外部 URI 要匹配的 path。
  final String path;

  /// 命中该路由后是否必须先完成认证。
  final bool requiresAuthentication;
}
