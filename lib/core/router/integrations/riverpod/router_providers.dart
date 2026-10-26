import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_router_definition.dart';
import '../../guards/app_route_request.dart';
import '../../guards/route_access_decision.dart';
import '../../navigation/base_navigator.dart';
import '../../navigation/router_navigator.dart';

/// 由 Router runtime 注入具体实现的导航接口 Provider。
final routerNavigatorBindingProvider = Provider<BaseNavigator>((ref) {
  throw StateError(
    'routerNavigatorBindingProvider must be overridden by the router runtime.',
  );
});

/// Flutter 根组件消费的 Router 配置，不暴露具体路由引擎类型。
final routerConfigProvider = Provider<RouterConfig<Object>>((ref) {
  throw StateError(
    'routerConfigProvider must be overridden by the Router runtime.',
  );
});

/// 面向业务层的稳定导航 Provider。
final appRouterProvider = Provider<BaseNavigator>((ref) {
  return RouterNavigator(ref.watch(routerNavigatorBindingProvider));
});

/// App 路由定义由 Riverpod 注入，供 runtime 集成消费。
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
