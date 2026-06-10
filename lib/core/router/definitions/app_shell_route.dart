import 'package:flutter/widgets.dart';

import 'app_route_node.dart';
import 'app_route_state.dart';
import 'app_shell_branch.dart';
import 'app_shell_navigator.dart';

/// Shell 路由节点。
class AppShellRoute extends AppRouteNode {
  const AppShellRoute({
    required this.branches,
    required this.builder,
    this.public = false,
  });

  /// Shell 下的分支列表。
  final List<AppShellBranch> branches;

  /// 构建 Shell 页面。
  final Widget Function(
    BuildContext context,
    AppRouteState state,
    AppShellNavigator shellNavigator,
  )
  builder;

  @override
  final bool public;
}
