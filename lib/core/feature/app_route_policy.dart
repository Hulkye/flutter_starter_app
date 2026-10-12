/// Feature 对单条路由声明的静态访问要求。
///
/// 该策略不读取认证等运行态；运行态判断由 AppRouteGuard 完成。
final class AppRoutePolicy {
  const AppRoutePolicy({
    required this.routeKey,
    this.requiresAuthentication = true,
  });

  /// 对应 AppRouteMetadata.key。
  final String routeKey;

  /// 是否要求有效认证会话。
  final bool requiresAuthentication;
}
