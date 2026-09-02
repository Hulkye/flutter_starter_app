import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/capability/app_capability.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_feature_registry.dart';
import 'package:flutter_starter_app/core/navigation/app_navigation_command.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/shared/services/auth/auth.dart';

import '../domain/deep_link_models.dart';
import '../infrastructure/app_links_source.dart';
import 'deep_link_resolver.dart';

/// App 层统一接收、暂存并分发深链命令。
final class DeepLinkCoordinator implements DeepLinkCapability {
  DeepLinkCoordinator({
    required this.read,
    required this.resolver,
    required this.requestAuthentication,
    AppLinksSource? source,
  }) : _source = source ?? AppLinksSource();

  /// Provider 读取入口。
  final ProviderListenableReader read;

  /// 已配置安全边界的链接解析器。
  final DeepLinkResolver resolver;

  /// 请求 App 进入认证流程，由 App 组合层决定具体导航目标。
  final void Function() requestAuthentication;

  final AppLinksSource _source;
  StreamSubscription<Uri>? _subscription;
  AppNavigationCommand? _pendingCommand;
  bool _bootstrapCompleted = false;
  bool _started = false;
  String? _lastUri;

  @override
  void start() {
    if (_started) return;
    _started = true;
    _subscription = _source.listen(handleUri);
  }

  /// 接收一个平台链接事件。
  void handleUri(Uri uri) {
    final uriValue = uri.toString();
    if (_lastUri == uriValue) return;
    _lastUri = uriValue;
    final resolution = resolver.resolve(uri);
    if (resolution is! DeepLinkAccepted) return;
    _pendingCommand = resolution.command;
    _dispatchIfReady();
  }

  @override
  void onBootstrapCompleted() {
    _bootstrapCompleted = true;
    _dispatchIfReady();
  }

  @override
  void onAuthenticationChanged() => _dispatchIfReady();

  @override
  bool dispatchAuthenticatedCommand() {
    if (!_bootstrapCompleted || _pendingCommand == null) return false;
    if (read(authSessionProvider)?.isValid != true) return false;
    _dispatchIfReady();
    return true;
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _dispatchIfReady() {
    if (!_bootstrapCompleted) return;
    final command = _pendingCommand;
    if (command == null) return;

    final authenticated = read(authSessionProvider)?.isValid == true;
    if (command.requiresAuthentication && !authenticated) {
      requestAuthentication();
      return;
    }

    _pendingCommand = null;
    read(appRouterProvider).replaceAll(command.location, extra: command.extra);
  }
}

typedef ProviderListenableReader =
    T Function<T>(ProviderListenable<T> provider);

/// 构建 App 深链相关 Provider 覆盖项。
List<Override> createDeepLinkOverrides(
  AppFeatureRegistry featureRegistry, {
  required void Function(Ref ref) requestAuthentication,
}) {
  return <Override>[
    deepLinkCoordinatorProvider.overrideWith(
      (ref) => DeepLinkCoordinator(
        read: ref.read,
        requestAuthentication: () => requestAuthentication(ref),
        resolver: DeepLinkResolver(
          config: appConfig,
          routes: featureRegistry.allRoutes,
        ),
      ),
    ),
  ];
}

/// 兼容现有调用点的 Provider，实际实现由 App 组合层覆盖。
final deepLinkCoordinatorProvider = Provider<DeepLinkCapability>(
  (ref) => const _DisabledDeepLinkCapability(),
);

final class _DisabledDeepLinkCapability implements DeepLinkCapability {
  const _DisabledDeepLinkCapability();

  @override
  void start() {}

  @override
  void onBootstrapCompleted() {}

  @override
  void onAuthenticationChanged() {}

  @override
  bool dispatchAuthenticatedCommand() => false;

  @override
  Future<void> dispose() async {}
}
