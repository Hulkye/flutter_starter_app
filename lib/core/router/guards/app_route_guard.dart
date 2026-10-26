import '../definitions/navigation/app_route_target.dart';
import 'route_access_decision.dart';
import 'app_route_request.dart';

/// 单一访问规则。
abstract interface class AppRouteGuard {
  const AppRouteGuard();

  RouteAccessDecision evaluate(AppRouteRequest request);
}

/// 按声明顺序组合多个访问规则。
///
/// 第一个重定向决策立即终止后续规则；允许决策中的入口替代目标会被合并。
final class AppRouteGuardChain {
  const AppRouteGuardChain(this.guards);

  final List<AppRouteGuard> guards;

  RouteAccessDecision evaluate(AppRouteRequest request) {
    final mergedRedirects = <String, AppRouteTarget>{};

    for (final guard in guards) {
      final decision = guard.evaluate(request);
      switch (decision) {
        case RedirectRoute():
          return decision;
        case AllowRoute(redirects: final guardRedirects):
          for (final entry in guardRedirects.entries) {
            final existing = mergedRedirects[entry.key];
            if (existing != null && existing.location != entry.value.location) {
              throw StateError(
                'Route guard redirect conflict "${entry.key}": '
                '${existing.location} and ${entry.value.location}',
              );
            }
            mergedRedirects[entry.key] = entry.value;
          }
      }
    }

    return AllowRoute(redirects: Map.unmodifiable(mergedRedirects));
  }
}
