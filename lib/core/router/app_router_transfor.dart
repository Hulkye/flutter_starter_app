import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_route_define.dart';

/// GoRouter 适配器：把框架无关的 [AppRouteDefine] 转换为 [GoRoute]。
GoRoute toGoRoute(AppRouteDefine route) {
  return GoRoute(
    path: route.path,
    name: route.path,
    pageBuilder: (context, state) {
      return _slideTransition(
        state,
        route.buildPage(
          context,
          RouteState(
            location: state.uri.toString(),
            pathParameters: state.pathParameters,
            queryParameters: state.uri.queryParameters,
            extra: state.extra,
          ),
        ),
      );
    },
  );
}

/// 统一页面过渡（从右向左滑入）。
Page<dynamic> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<dynamic>(
    key: state.pageKey,
    name: state.name,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ),
        ),
        child: child,
      );
    },
  );
}
