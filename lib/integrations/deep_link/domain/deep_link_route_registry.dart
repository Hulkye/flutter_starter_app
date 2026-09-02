import 'package:flutter_starter_app/core/router/router.dart';

/// App 组合层提供给 Deep Link 集成的路由注册表。
final class DeepLinkRouteRegistry {
  const DeepLinkRouteRegistry({this.routes = const <AppPageRoute>[]});

  /// 当前 App 允许被外部链接调用的路由。
  final List<AppPageRoute> routes;
}
