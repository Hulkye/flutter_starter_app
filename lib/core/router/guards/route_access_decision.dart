import '../definitions/app_route_target.dart';

/// 路由守卫消费的最终访问决策。
sealed class RouteAccessDecision {
  const RouteAccessDecision();
}

/// 允许访问当前路由。
///
/// [redirects] 用于声明少量入口页的替代目标，例如已登录用户访问登录页时
/// 返回首页。key 是当前路由匹配模式，value 是类型化导航目标。
final class AllowRoute extends RouteAccessDecision {
  const AllowRoute({this.redirects = const <String, AppRouteTarget>{}});

  final Map<String, AppRouteTarget> redirects;
}

/// 将当前访问重定向到指定目标。
final class RedirectRoute extends RouteAccessDecision {
  const RedirectRoute({
    required this.target,
    this.preserveTarget = false,
    this.appliesToPublicRoutes = false,
  });

  /// 重定向目标。
  final AppRouteTarget target;

  /// 是否将当前 location 作为成功后的回跳目标。
  final bool preserveTarget;

  /// 是否覆盖公开路由。
  final bool appliesToPublicRoutes;
}
