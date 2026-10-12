import '../definitions/app_route_target.dart';

/// 应用导航接口。
///
/// Presentation 层依赖该接口，而不是直接依赖 GoRouter。
/// ViewModel、Widget、测试都可以使用同一套导航协议。
abstract interface class BaseNavigator {
  /// 当前完整 location。
  String get location;

  /// 使用类型化目标跳转并替换当前页面。
  void go(AppRouteTarget target);

  /// 使用类型化目标压栈打开页面，可返回结果。
  Future<T?> push<T extends Object?>(AppRouteTarget target);

  /// 使用类型化目标替换当前页面。
  void replace(AppRouteTarget target);

  /// 使用类型化目标清空当前栈并跳转。
  void replaceAll(AppRouteTarget target);

  /// 兼容期字符串跳转 API。
  void goLocation(String location, {Object? extra});

  /// 兼容期字符串压栈 API。
  Future<T?> pushLocation<T extends Object?>(String location, {Object? extra});

  /// 兼容期字符串替换 API。
  void replaceLocation(String location, {Object? extra});

  /// 兼容期字符串清栈跳转 API。
  void replaceAllLocation(String location, {Object? extra});

  /// 返回上一页。
  void back<T extends Object?>([T? result]);

  /// 是否可以返回。
  bool canBack();
}
