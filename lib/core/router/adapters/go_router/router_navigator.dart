import 'package:go_router/go_router.dart';

import '../../definitions/navigation/app_route_target.dart';
import '../../guards/internal_route_location.dart';
import '../../navigation/base_navigator.dart';

/// [BaseNavigator] 的 GoRouter 实现。
///
/// 这是项目中唯一直接调用 GoRouter 导航 API 的类。
final class RouterNavigator implements BaseNavigator {
  RouterNavigator(this._router);

  final GoRouter _router;

  @override
  String get location => _router.state.uri.toString();

  @override
  void go(AppRouteTarget target) {
    _router.go(requireInternalLocation(target.location), extra: target.extra);
  }

  @override
  Future<T?> push<T extends Object?>(AppRouteTarget target) {
    return _router.push<T>(
      requireInternalLocation(target.location),
      extra: target.extra,
    );
  }

  @override
  void replace(AppRouteTarget target) {
    _router.replace(
      requireInternalLocation(target.location),
      extra: target.extra,
    );
  }

  @override
  void replaceAll(AppRouteTarget target) {
    _router.go(requireInternalLocation(target.location), extra: target.extra);
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
