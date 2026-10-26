import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../adapters/go_router/router_factory.dart';
import '../../guards/app_route_request.dart';
import '../../guards/route_access_decision.dart';
import 'router_providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final definition = ref.watch(appRouterDefinitionProvider);
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<RouteAccessDecision Function(AppRouteRequest)>(
    routeAccessDecisionProvider,
    (_, _) => refreshNotifier.refresh(),
  );

  return createGoRouter(
    definition: definition,
    accessDecision: (request) => ref.read(routeAccessDecisionProvider)(request),
    refreshListenable: refreshNotifier,
  );
});

List<Override> createRouterRuntimeOverrides() => <Override>[
  routerConfigProvider.overrideWith((ref) => ref.watch(goRouterProvider)),
  routerNavigatorBindingProvider.overrideWith(
    (ref) => createGoRouterNavigator(ref.watch(goRouterProvider)),
  ),
];

final class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
