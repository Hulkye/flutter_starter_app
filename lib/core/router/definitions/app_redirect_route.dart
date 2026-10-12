import 'app_route_node.dart';
import 'app_route_metadata.dart';

/// 只负责重定向的路由节点。
class AppRedirectRoute extends AppRouteNode {
  const AppRedirectRoute({required this.path, required this.redirectTo});

  /// 路由匹配模式。
  final String path;

  /// 重定向目标 location。
  final String redirectTo;

  AppRouteMetadata get metadata => AppRouteMetadata(key: path, path: path);
}
