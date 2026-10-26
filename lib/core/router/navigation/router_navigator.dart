import '../definitions/app_route_target.dart';
import 'base_navigator.dart';

/// Router 导航门面，向模块外提供稳定的导航入口。
///
/// 具体路由引擎由集成层选择并注入，调用方不依赖引擎实现。
final class RouterNavigator implements BaseNavigator {
  const RouterNavigator(this._delegate);

  final BaseNavigator _delegate;

  @override
  String get location => _delegate.location;

  @override
  void go(AppRouteTarget target) => _delegate.go(target);

  @override
  Future<T?> push<T extends Object?>(AppRouteTarget target) {
    return _delegate.push<T>(target);
  }

  @override
  void replace(AppRouteTarget target) => _delegate.replace(target);

  @override
  void replaceAll(AppRouteTarget target) => _delegate.replaceAll(target);

  @override
  void back<T extends Object?>([T? result]) => _delegate.back<T>(result);

  @override
  bool canBack() => _delegate.canBack();
}
