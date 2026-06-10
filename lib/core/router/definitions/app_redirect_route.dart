import 'app_route_node.dart';

/// 只负责重定向的路由节点。
class AppRedirectRoute extends AppRouteNode {
  const AppRedirectRoute({
    required this.path,
    required this.redirectTo,
    this.public = false,
  });

  /// 路由匹配模式。
  final String path;

  /// 重定向目标 location。
  final String redirectTo;

  @override
  final bool public;
}
