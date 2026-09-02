import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/router/router.dart';

import 'app_feature.dart';
import 'app_tab_entry.dart';

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

  /// 当前环境启用的普通路由。
  late final List<AppPageRoute> routes = [
    for (final feature in features)
      for (final route in feature.routes)
        if (!_tabRoutePaths.contains(route.path)) route,
  ];

  /// 当前环境所有已注册页面路由，包含底部 Tab 路由。
  late final List<AppPageRoute> allRoutes = [
    ...routes,
    for (final tab in tabs)
      if (!routes.any((route) => route.path == tab.route.path)) tab.route,
  ];

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
    for (final feature in features) {
      for (final route in feature.routes) {
        _validateRoutePath(routes, route.path, feature.key);
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
}
