import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'access_guard.dart';
import 'route_transform.dart';
import 'router_navigator.dart' as go_router;
import '../../config/app_router_definition.dart';
import '../../definitions/router_definitions.dart';
import '../../guards/route_access_decision.dart';
import '../../guards/app_route_request.dart';
import '../../navigation/router_provider.dart';

final _goRouterNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter runtime Provider.
final goRouterProvider = Provider<GoRouter>((ref) {
  final routerConfig = ref.watch(appRouterDefinitionProvider);
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<RouteAccessDecision Function(AppRouteRequest)>(
    routeAccessDecisionProvider,
    (_, _) => refreshNotifier.refresh(),
  );

  return GoRouter(
    navigatorKey: _goRouterNavigatorKey,
    initialLocation: routerConfig.initialLocation,
    observers: routerConfig.observers,
    refreshListenable: refreshNotifier,
    redirect: createGoRouterAccessGuard(
      accessDecision: (request) =>
          ref.read(routeAccessDecisionProvider)(request),
      routeNodes: routerConfig.routeNodes,
      publicPaths: routerConfig.publicRoutePatterns,
    ),
    errorBuilder: (context, state) {
      final error = AppRouteError(
        location: state.uri.toString(),
        message: state.error?.toString() ?? 'Unknown routing error',
        exception: state.error,
      );
      return routerConfig.errorBuilder?.call(context, error) ??
          GoRouterErrorView(error: error);
    },
    routes: routerConfig.routeNodes.map(toRouteBase).toList(),
  );
});

/// Flutter RouterConfig 是 App 根组件所需的唯一 runtime 入口。
final appRouterConfigProvider = Provider<RouterConfig<Object>>((ref) {
  return ref.watch(goRouterProvider);
});

List<Override> createGoRouterRuntimeOverrides() => <Override>[
  appRouterDefinitionProvider.overrideWith((ref) {
    throw StateError(
      'appRouterDefinitionProvider must be overridden by the app composition layer.',
    );
  }),
  routerConfigProvider.overrideWith(
    (ref) => ref.watch(appRouterConfigProvider),
  ),
  routerNavigatorBindingProvider.overrideWith(
    (ref) => go_router.RouterNavigator(ref.watch(goRouterProvider)),
  ),
];

final class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

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
            const Text('页面无法打开'),
            const SizedBox(height: 8),
            Text(error.location),
          ],
        ),
      ),
    );
  }
}
