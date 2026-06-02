import 'package:go_router/go_router.dart';

import 'base_navigator.dart';
import 'app_route_define.dart';

/// [BaseNavigator] 的 GoRouter 实现。
///
/// 这是项目中唯一直接调用 GoRouter 导航 API 的类。
final class RouterNavigator implements BaseNavigator {
  RouterNavigator(this._router);

  final GoRouter _router;

  @override
  void go(AppRouteDefine route) {
    _router.go(route.location);
  }

  @override
  Future<T?> push<T extends Object?>(AppRouteDefine route) {
    return _router.push<T>(route.location);
  }

  @override
  void replace(AppRouteDefine route) {
    _router.replace(route.location);
  }

  @override
  void replaceAll(AppRouteDefine route) {
    _router.go(route.location);
  }

  @override
  void back<T extends Object?>([T? result]) {
    if (_router.canPop()) {
      _router.pop<T>(result);
    }
  }

  @override
  bool canBack() => _router.canPop();
}
