import 'package:go_router/go_router.dart';

import 'base_navigator.dart';

/// [BaseNavigator] 的 GoRouter 实现。
///
/// 这是项目中唯一直接调用 GoRouter 导航 API 的类。
final class RouterNavigator implements BaseNavigator {
  RouterNavigator(this._router);

  final GoRouter _router;

  @override
  void go(String location) {
    _router.go(location);
  }

  @override
  Future<T?> push<T extends Object?>(String location) {
    return _router.push<T>(location);
  }

  @override
  void replace(String location) {
    _router.replace(location);
  }

  @override
  void replaceAll(String location) {
    _router.go(location);
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
