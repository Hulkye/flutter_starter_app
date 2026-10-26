import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../adapters/router_navigator.dart';
import 'base_navigator.dart';

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
