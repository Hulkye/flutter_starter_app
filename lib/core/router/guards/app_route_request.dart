import '../definitions/app_route_metadata.dart';
import '../definitions/app_route_state.dart';

/// Guard 判断当前访问时使用的路由上下文。
final class AppRouteRequest {
  const AppRouteRequest({
    required this.location,
    required this.routeKey,
    required this.metadata,
    required this.state,
  });

  /// 当前完整 location。
  final String location;

  /// 当前路由的稳定 key。
  final String routeKey;

  /// 当前路由注册元数据。
  final AppRouteMetadata metadata;

  /// 当前框架无关的路由状态。
  final AppRouteState state;
}
