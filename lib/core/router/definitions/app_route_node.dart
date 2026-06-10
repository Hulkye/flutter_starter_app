/// 应用路由节点。
///
/// 比 AppPageRoute 更高一层，可表达普通页面、重定向、ShellRoute 等
/// 不同类型的路由结构。
abstract class AppRouteNode {
  const AppRouteNode();

  /// 该节点是否无需登录即可访问。
  bool get public => false;
}
