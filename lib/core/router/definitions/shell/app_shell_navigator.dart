import 'package:flutter/widgets.dart';

/// 框架无关的 Shell 分支导航接口。
///
/// App Shell 页面依赖该接口切换底部 Tab，不直接依赖 GoRouter 的
/// StatefulNavigationShell。
abstract interface class AppShellNavigator {
  /// 当前选中的分支索引。
  int get currentIndex;

  /// 当前分支内容。
  Widget get child;

  /// 切换到指定分支。
  void goBranch(int index, {bool initialLocation = false});
}
