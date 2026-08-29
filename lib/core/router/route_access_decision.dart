/// 路由守卫消费的最终访问决策。
sealed class RouteAccessDecision {
  const RouteAccessDecision();
}

/// 允许访问当前路由。
///
/// [redirects] 用于声明少量入口页的替代目标，例如已登录用户访问登录页时
/// 返回首页。key 和 value 均为应用内 location。
final class AllowRoute extends RouteAccessDecision {
  const AllowRoute({this.redirects = const <String, String>{}});

  final Map<String, String> redirects;
}

/// 将当前访问重定向到指定 location。
final class RedirectRoute extends RouteAccessDecision {
  const RedirectRoute({
    required this.location,
    this.preserveTarget = false,
    this.appliesToPublicRoutes = false,
  });

  /// 重定向目标 location。
  final String location;

  /// 是否将当前 location 作为成功后的回跳目标。
  final bool preserveTarget;

  /// 是否覆盖公开路由。
  final bool appliesToPublicRoutes;
}
