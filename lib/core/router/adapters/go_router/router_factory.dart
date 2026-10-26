import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'access_guard.dart';
import 'route_transform.dart';
import 'router_navigator.dart';
import '../../config/app_router_definition.dart';
import '../../definitions/state/app_route_error.dart';
import '../../guards/app_route_request.dart';
import '../../guards/route_access_decision.dart';

final _goRouterNavigatorKey = GlobalKey<NavigatorState>();

/// 根据中立路由定义创建 GoRouter runtime。
GoRouter createGoRouter({
  required AppRouterDefinition definition,
  required RouteAccessDecision Function(AppRouteRequest) accessDecision,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    navigatorKey: _goRouterNavigatorKey,
    initialLocation: definition.initialLocation,
    observers: definition.observers,
    refreshListenable: refreshListenable,
    redirect: createGoRouterAccessGuard(
      accessDecision: accessDecision,
      routeNodes: definition.routeNodes,
      publicPaths: definition.publicRoutePatterns,
    ),
    errorBuilder: (context, state) {
      final error = AppRouteError(
        location: state.uri.toString(),
        message: state.error?.toString() ?? 'Unknown routing error',
        exception: state.error,
      );
      return definition.errorBuilder?.call(context, error) ??
          GoRouterErrorView(error: error);
    },
    routes: definition.routeNodes.map(toRouteBase).toList(),
  );
}

/// 将 GoRouter 导航对象适配为项目级导航接口。
RouterNavigator createGoRouterNavigator(GoRouter router) =>
    RouterNavigator(router);

final class GoRouterErrorView extends StatelessWidget {
  const GoRouterErrorView({required this.error, super.key});

  final AppRouteError error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline),
            const SizedBox(height: 12),
            Text(error.location),
          ],
        ),
      ),
    );
  }
}
