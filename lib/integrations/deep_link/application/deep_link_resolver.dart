import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/navigation/app_navigation_command.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/shared/webview/domain/web_page_config.dart';
import 'package:flutter_starter_app/shared/webview/presentation/webview_routes.dart';

import '../domain/deep_link_models.dart';

/// App 层统一解析外部链接，不让业务页面分别处理 URL。
final class DeepLinkResolver {
  const DeepLinkResolver({
    required this.config,
    this.routes = const <AppPageRoute>[],
  });

  /// 当前运行环境的链接安全配置。
  final EnvConfig config;

  /// App 组合层注册的可用深链路由。
  final List<AppPageRoute> routes;

  /// 将原始 URI 解析为已校验的 App 命令。
  DeepLinkResolution resolve(Uri? uri) {
    if (uri == null || uri.toString().trim().isEmpty) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.invalidUri);
    }
    if (_hasUnsafeParts(uri)) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.unsafeUri);
    }

    final source = _resolveSource(uri);
    if (source == null) {
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        return const DeepLinkInvalid(DeepLinkInvalidReason.blockedHost);
      }
      return const DeepLinkInvalid(DeepLinkInvalidReason.unsupportedScheme);
    }

    final queryParameters = uri.queryParametersAll;
    if (uri.path == WebPageRoute.pathValue) {
      return _resolveWeb(uri);
    }

    final route = _findRoute(uri.path);
    if (route == null) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.unknownPath);
    }
    final query = _readQuery(queryParameters);

    return DeepLinkAccepted(
      AppNavigationCommand(
        source: AppNavigationSource.deepLink,
        path: route.path,
        requiresAuthentication: !route.public,
        queryParameters: query,
      ),
    );
  }

  DeepLinkSource? _resolveSource(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final configuredScheme =
        config.deepLinkConfig?.appScheme.trim().toLowerCase() ?? '';
    if (configuredScheme.isNotEmpty && scheme == configuredScheme) {
      if (uri.host.isNotEmpty) return null;
      return DeepLinkSource.appScheme;
    }
    if (scheme != 'http' && scheme != 'https') return null;
    return DeepLinkSource.appLink;
  }

  DeepLinkResolution _resolveWeb(Uri uri) {
    final rawUrl = uri.queryParameters['url'];
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.invalidQuery);
    }
    final webUrl = _normalizeWebUrl(rawUrl);
    if (webUrl == null) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.invalidQuery);
    }
    return DeepLinkAccepted(
      AppNavigationCommand(
        source: AppNavigationSource.deepLink,
        path: const WebPageRoute().path,
        requiresAuthentication: false,
        queryParameters: <String, String>{'url': webUrl},
        extra: WebPageConfig(url: webUrl),
      ),
    );
  }

  AppPageRoute? _findRoute(String path) {
    for (final route in routes) {
      if (route.deepLinkEnabled && route.path == path) return route;
    }
    return null;
  }

  Map<String, String> _readQuery(Map<String, List<String>> parameters) {
    final queryParameters = <String, String>{};
    for (final entry in parameters.entries) {
      queryParameters[entry.key] = entry.value.first;
    }
    return queryParameters;
  }

  bool _hasUnsafeParts(Uri uri) {
    return uri.userInfo.isNotEmpty || uri.fragment.isNotEmpty;
  }

  String? _normalizeWebUrl(String value) {
    final trimmed = value.trim();
    final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
    final uri = WebPageConfig.normalizeWebUri(candidate);
    return uri?.toString();
  }
}
