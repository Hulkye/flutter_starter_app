import 'dart:async';

import 'package:app_deep_link/app_deep_link.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/capability/app_capability.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/navigation/app_navigation_command.dart';
import 'package:flutter_starter_app/shared/webview/domain/web_page_config.dart';
import 'package:flutter_starter_app/shared/webview/presentation/webview_routes.dart';

import '../../app/navigation/app_external_route_registry.dart';
import '../../app/navigation/pending_navigation_coordinator.dart';

/// 当前宿主对独立 Deep Link package 的适配层。
///
/// 它只负责把 package 的通用匹配结果转换为 AppNavigationCommand，认证等待和
/// 实际导航交给 App 层的 PendingNavigationCoordinator。
final class DeepLinkAppCapability implements AppCapability {
  DeepLinkAppCapability({
    required this.engine,
    required this.pendingNavigation,
  });

  final DeepLinkEngine engine;
  final PendingNavigationCoordinator pendingNavigation;

  /// 防止生命周期重复启动平台监听。
  bool _started = false;

  /// 启动冷启动 URI 和后续 URI 的统一监听。
  @override
  void start() {
    if (_started) return;
    _started = true;
    unawaited(engine.start(_handleResolution));
  }

  /// 将 bootstrap 生命周期转发给待处理导航协调器。
  @override
  void onBootstrapCompleted() {
    pendingNavigation.onBootstrapCompleted();
  }

  /// 将认证状态变化转发给待处理导航协调器。
  @override
  void onAuthenticationChanged() => pendingNavigation.onAuthenticationChanged();

  /// 释放 package 持有的平台资源。
  @override
  Future<void> dispose() => engine.dispose();

  /// 忽略无效结果，只把已校验的 URI 转换成宿主导航命令。
  void _handleResolution(DeepLinkResolution resolution) {
    if (resolution is! DeepLinkAccepted) return;
    final command = _toCommand(resolution.match);
    if (command == null) return;
    pendingNavigation.submit(command);
  }

  /// 宿主专属映射：WebView 参数和 AppNavigationCommand 不属于 package。
  AppNavigationCommand? _toCommand(DeepLinkMatch match) {
    if (match.route.key == WebPageRoute.pathValue) {
      final rawUrl = match.queryParameters['url'];
      if (rawUrl == null || rawUrl.trim().isEmpty) return null;
      final normalizedUrl = _normalizeWebUrl(rawUrl);
      if (normalizedUrl == null) return null;
      return AppNavigationCommand(
        source: AppNavigationSource.deepLink,
        path: const WebPageRoute().path,
        requiresAuthentication: false,
        queryParameters: <String, String>{'url': normalizedUrl},
        extra: WebPageConfig(url: normalizedUrl),
      );
    }
    return AppNavigationCommand(
      source: AppNavigationSource.deepLink,
      path: match.route.path,
      requiresAuthentication: match.route.requiresAuthentication,
      queryParameters: match.queryParameters,
    );
  }

  String? _normalizeWebUrl(String value) {
    final trimmed = value.trim();
    final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
    return WebPageConfig.normalizeWebUri(candidate)?.toString();
  }
}

/// 在 App 组合层创建可选的 Deep Link capability override。
///
/// 只有存在 [EnvConfig.deepLinkConfig] 时才调用此方法，因此未启用 Deep Link
/// 的宿主不会创建 engine，也不会订阅平台 URI。
List<Override> createDeepLinkAppOverrides() {
  return <Override>[
    deepLinkAppCapabilityProvider.overrideWith((ref) {
      final config = appConfig.deepLinkConfig;
      if (config == null) {
        throw StateError('Deep Link capability requires deepLinkConfig.');
      }
      return DeepLinkAppCapability(
        engine: DeepLinkEngine(
          config: config,
          routes: createExternalDeepLinkRoutes(),
        ),
        pendingNavigation: ref.read(pendingNavigationCoordinatorProvider),
      );
    }),
  ];
}

final deepLinkAppCapabilityProvider = Provider<AppCapability>(
  (ref) => throw StateError('Deep Link capability is not configured.'),
);
