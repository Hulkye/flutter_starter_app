import 'package:go_router/go_router.dart';

import 'base_navigator.dart';

/// [BaseNavigator] 的 GoRouter 实现。
///
/// 这是项目中唯一直接调用 GoRouter 导航 API 的类。
final class RouterNavigator implements BaseNavigator {
  RouterNavigator(this._router);

  final GoRouter _router;

  @override
  String get location => _router.state.uri.toString();

  @override
  void go(String location, {Object? extra}) {
    _router.go(location, extra: extra);
  }

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return _router.push<T>(location, extra: extra);
  }

  @override
  void replace(String location, {Object? extra}) {
    _router.replace(location, extra: extra);
  }

  @override
  void replaceAll(String location, {Object? extra}) {
    _router.go(location, extra: extra);
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
