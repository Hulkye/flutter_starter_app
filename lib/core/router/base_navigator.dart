import 'app_route_define.dart';

/// 应用导航接口。
///
/// Presentation 层依赖该接口，而不是直接依赖 GoRouter。
/// ViewModel、Widget、测试都可以使用同一套导航协议。
abstract interface class BaseNavigator {
  /// 跳转到目标路由并替换当前 location（适合 tab 切换/回首页）。
  void go(AppRouteDefine route);

  /// 压栈打开目标路由，可返回结果。
  Future<T?> push<T extends Object?>(AppRouteDefine route);

  /// 替换当前页。
  void replace(AppRouteDefine route);

  /// 清空当前栈并跳转。
  void replaceAll(AppRouteDefine route);

  /// 返回上一页。
  void back<T extends Object?>([T? result]);

  /// 是否可以返回。
  bool canBack();
}
