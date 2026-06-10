import 'package:flutter/widgets.dart';

import 'app_page_route.dart';

/// StatefulShellRoute 分支定义。
final class AppShellBranch {
  const AppShellBranch({
    required this.routes,
    this.navigatorKey,
    this.initialLocation,
  });

  /// 分支独立 Navigator Key。
  final GlobalKey<NavigatorState>? navigatorKey;

  /// 分支初始 location。
  final String? initialLocation;

  /// 当前分支下的页面路由。
  final List<AppPageRoute> routes;
}
