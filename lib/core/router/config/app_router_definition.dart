import 'package:flutter/widgets.dart';
import '../definitions/router_definitions.dart';

/// App 组合层提供的路由图与展示配置，不依赖具体 Router 引擎。
final class AppRouterDefinition {
  const AppRouterDefinition({
    required this.routeNodes,
    required this.initialLocation,
    this.publicRoutePatterns = const <String>[],
    this.observers = const <NavigatorObserver>[],
    this.errorBuilder,
  });

  final List<AppRouteNode> routeNodes;
  final String initialLocation;
  final List<String> publicRoutePatterns;
  final List<NavigatorObserver> observers;
  final Widget Function(BuildContext context, AppRouteError error)?
  errorBuilder;
}
