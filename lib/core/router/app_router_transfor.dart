import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../constant/duration_const.dart';
import 'definitions/router_definitions.dart';

/// GoRouter 适配器：把框架无关的 [AppRouteNode] 转换为 [RouteBase]。
RouteBase toRouteBase(AppRouteNode node) {
  if (node is AppPageRoute) return toGoRoute(node);
  if (node is AppRedirectRoute) return _toRedirectRoute(node);
  if (node is AppShellRoute) return _toShellRoute(node);
  throw UnsupportedError('Unsupported route node: ${node.runtimeType}');
}

/// GoRouter 适配器：把框架无关的 [AppPageRoute] 转换为 [GoRoute]。
GoRoute toGoRoute(AppPageRoute route) {
  return GoRoute(
    path: route.path,
    name: route.path,
    pageBuilder: (context, state) {
      return _swipeablePage(
        context: context,
        state: state,
        builder: (context) => route.buildPage(context, toAppRouteState(state)),
      );
    },
  );
}

/// 把 GoRouterState 转为框架无关的 [AppRouteState]。
AppRouteState toAppRouteState(GoRouterState state) {
  return AppRouteState(
    location: state.uri.toString(),
    pathParameters: state.pathParameters,
    queryParameters: state.uri.queryParameters,
    extra: state.extra,
  );
}

GoRoute _toRedirectRoute(AppRedirectRoute route) {
  return GoRoute(
    path: route.path,
    name: route.path,
    redirect: (context, state) => route.redirectTo,
  );
}

StatefulShellRoute _toShellRoute(AppShellRoute route) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return route.builder(
        context,
        toAppRouteState(state),
        _NavigationShellAdapter(navigationShell),
      );
    },
    branches: [
      for (final branch in route.branches)
        StatefulShellBranch(
          navigatorKey: branch.navigatorKey,
          initialLocation: branch.initialLocation,
          routes: [for (final route in branch.routes) toGoRoute(route)],
        ),
    ],
  );
}

final class _NavigationShellAdapter implements AppShellNavigator {
  const _NavigationShellAdapter(this._navigationShell);

  final StatefulNavigationShell _navigationShell;

  @override
  int get currentIndex => _navigationShell.currentIndex;

  @override
  Widget get child => _navigationShell;

  @override
  void goBranch(int index, {bool initialLocation = false}) {
    _navigationShell.goBranch(index, initialLocation: initialLocation);
  }
}

/// 统一路由页面，支持从页面任意位置滑动返回。
Page<dynamic> _swipeablePage({
  required BuildContext context,
  required GoRouterState state,
  required WidgetBuilder builder,
}) {
  final textDirection = Directionality.of(context);
  // 触发边缘滑动返回的区域宽度
  const backGestureDetectionWidth = 48.0;
  // 触发边缘滑动返回的区域起始横坐标
  double backGestureDetectionStartOffset;
  if (textDirection == TextDirection.rtl) {
    backGestureDetectionStartOffset =
        MediaQuery.of(context).size.width - backGestureDetectionWidth;
  } else {
    backGestureDetectionStartOffset = 0.0;
  }
  return SwipeablePage<dynamic>(
    key: state.pageKey,
    name: state.name,
    backGestureDetectionWidth: backGestureDetectionWidth,
    backGestureDetectionStartOffset: backGestureDetectionStartOffset,
    canOnlySwipeFromEdge: true,
    transitionDuration: DurationConst.pageTransition,
    reverseTransitionDuration: DurationConst.pageTransition,
    builder: builder,
  );
}
