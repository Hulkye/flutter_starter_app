import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../definitions/router_definitions.dart';
import '../guards/app_route_request.dart';
import '../guards/route_access_decision.dart';

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

final appRouterDefinitionProvider = Provider<AppRouterDefinition>((ref) {
  throw StateError(
    'appRouterDefinitionProvider must be overridden by the app composition layer.',
  );
});

final routeAccessDecisionProvider =
    Provider<RouteAccessDecision Function(AppRouteRequest)>((ref) {
      throw StateError(
        'routeAccessDecisionProvider must be overridden by the app composition layer.',
      );
    });
