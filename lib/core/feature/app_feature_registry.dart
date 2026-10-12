import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/router/router.dart';

import 'app_feature.dart';
import 'app_external_route.dart';
import 'app_tab_entry.dart';
import 'app_route_policy.dart';

/// 当前环境下的 Feature 注册结果。
///
/// 构造时完成筛选、排序和所有注册约束校验，避免路由、Tab 与 Provider
/// 从不同的 Feature 集合派生。
final class AppFeatureRegistry {
  AppFeatureRegistry({
    required Iterable<AppFeature> candidates,
    required this.environment,
  }) : features = _prepare(candidates, environment) {
    _validate(features);
  }

  /// 当前注册表使用的环境。
  final EnvTag environment;

  /// 当前环境中启用、并按注册顺序排列的 Feature。
  final List<AppFeature> features;

  /// 当前环境启用的 Tab。
  late final List<AppTabEntry> tabs = [
    for (final feature in features) ...feature.tabs,
  ];

  /// 当前环境启用的外部入口路由。
  late final List<AppExternalRoute> externalRoutes = [
    for (final feature in features) ...feature.externalRoutes,
  ];

  /// 当前环境启用的 Feature 级访问规则。
  late final List<AppRouteGuard> guards = [
    for (final feature in features) ...feature.guards,
  ];

  /// 当前环境启用的路由访问策略。
  late final List<AppRoutePolicy> routePolicies = [
    for (final feature in features) ...feature.routePolicies,
  ];

  /// 按 route key 索引访问策略。
  late final Map<String, AppRoutePolicy> routePoliciesByKey = Map.unmodifiable({
    for (final policy in routePolicies) policy.routeKey: policy,
  });

  /// 当前环境允许匿名访问的路由匹配模板。
  late final List<String> publicRoutePatterns = [
    for (final route in allRoutes)
      if (routePoliciesByKey[route.metadata.key]?.requiresAuthentication ==
          false)
        route.path,
  ];

  /// 当前环境启用的普通路由。
  late final List<AppPageRoute<dynamic>> routes = [
    for (final feature in features)
      for (final route in feature.routes)
        if (!_tabRoutePaths.contains(route.path)) route,
  ];

  /// 当前环境所有已注册页面路由，包含底部 Tab 路由。
  late final List<AppPageRoute<dynamic>> allRoutes = [
    ...routes,
    for (final tab in tabs)
      if (!routes.any((route) => route.path == tab.route.path)) tab.route,
  ];

  /// 按稳定 route metadata key 索引的页面路由。
  late final Map<String, AppPageRoute<dynamic>> routesByKey = Map.unmodifiable({
    for (final route in allRoutes) route.metadata.key: route,
  });

  /// 按匹配 path 索引的页面路由。
  late final Map<String, AppPageRoute<dynamic>> routesByPath = Map.unmodifiable(
    {for (final route in allRoutes) route.path: route},
  );

  /// 当前环境启用的 Provider 覆盖项。
  late final List<Override> providerOverrides = [
    for (final feature in features) ...feature.providerOverrides,
  ];

  Set<String> get _tabRoutePaths => {for (final tab in tabs) tab.route.path};

  static List<AppFeature> _prepare(
    Iterable<AppFeature> candidates,
    EnvTag environment,
  ) {
    final enabled = candidates
        .where((feature) => feature.metadata.isEnabledIn(environment))
        .toList();
    enabled.sort((left, right) {
      final priority = left.metadata.priority.compareTo(
        right.metadata.priority,
      );
      if (priority != 0) return priority;
      return left.key.compareTo(right.key);
    });
    return List.unmodifiable(enabled);
  }

  static void _validate(List<AppFeature> features) {
    final featureKeys = <String>{};
    for (final feature in features) {
      if (!featureKeys.add(feature.key)) {
        throw StateError('Feature key conflict "${feature.key}"');
      }
    }

    final routes = <String, String>{};
    final routeKeys = <String, String>{};
    for (final feature in features) {
      for (final route in feature.routes) {
        _validateRoutePath(routes, route.path, feature.key);
        _validateRouteKey(routeKeys, route.metadata.key, feature.key);
        if (route.metadata.path != route.path) {
          throw StateError(
            'Route metadata path mismatch for "${route.metadata.key}": '
            '${route.metadata.path} != ${route.path}',
          );
        }
      }
    }

    final routePolicies = <String, String>{};
    for (final feature in features) {
      final featureRouteKeys = {
        for (final route in feature.routes) route.metadata.key,
      };
      for (final policy in feature.routePolicies) {
        if (!featureRouteKeys.contains(policy.routeKey)) {
          throw StateError(
            'Route policy "${policy.routeKey}" in Feature "${feature.key}" '
            'references a route not declared by that Feature',
          );
        }
        final previousFeature = routePolicies[policy.routeKey];
        if (previousFeature != null) {
          throw StateError(
            'Route policy conflict "${policy.routeKey}": '
            '$previousFeature and ${feature.key}',
          );
        }
        routePolicies[policy.routeKey] = feature.key;
      }
    }

    final tabs = <String, String>{};
    for (final feature in features) {
      final routePaths = {for (final route in feature.routes) route.path};
      for (final tab in feature.tabs) {
        final previousFeature = tabs[tab.key];
        if (previousFeature != null) {
          throw StateError(
            'Tab key conflict "${tab.key}": $previousFeature and ${feature.key}',
          );
        }
        tabs[tab.key] = feature.key;
        if (!routePaths.contains(tab.route.path)) {
          throw StateError(
            'Tab "${tab.key}" in Feature "${feature.key}" references '
            'route "${tab.route.path}" not declared by that Feature',
          );
        }
      }
    }

    final externalRoutes = <String, String>{};
    final externalRoutePaths = <String, String>{};
    for (final feature in features) {
      final routePaths = {for (final route in feature.routes) route.path};
      for (final externalRoute in feature.externalRoutes) {
        final previousKeyFeature = externalRoutes[externalRoute.key];
        if (previousKeyFeature != null) {
          throw StateError(
            'External route key conflict "${externalRoute.key}": '
            '$previousKeyFeature and ${feature.key}',
          );
        }
        externalRoutes[externalRoute.key] = feature.key;

        final path = externalRoute.route.path;
        final previousPathFeature = externalRoutePaths[path];
        if (previousPathFeature != null) {
          throw StateError(
            'External route path conflict "$path": '
            '$previousPathFeature and ${feature.key}',
          );
        }
        externalRoutePaths[path] = feature.key;

        if (!routePaths.contains(path)) {
          throw StateError(
            'External route "${externalRoute.key}" in Feature '
            '"${feature.key}" references route "$path" not declared by '
            'that Feature',
          );
        }
      }
    }
  }

  static void _validateRoutePath(
    Map<String, String> routes,
    String path,
    String featureKey,
  ) {
    final previousFeature = routes[path];
    if (previousFeature != null) {
      throw StateError(
        'Route path conflict "$path": $previousFeature and $featureKey',
      );
    }
    routes[path] = featureKey;
  }

  static void _validateRouteKey(
    Map<String, String> routeKeys,
    String key,
    String featureKey,
  ) {
    final previousFeature = routeKeys[key];
    if (previousFeature != null) {
      throw StateError(
        'Route key conflict "$key": $previousFeature and $featureKey',
      );
    }
    routeKeys[key] = featureKey;
  }
}
