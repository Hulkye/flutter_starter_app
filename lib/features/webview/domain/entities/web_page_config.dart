import 'dart:typed_data';

import 'package:webview_flutter/webview_flutter.dart';

/// WebPage 入参配置。
///
/// 常用场景可通过 [WebPageRoute.location] 使用 query 参数传入 URL 和标题；
/// 需要 headers、白名单、WebView 行为开关时，通过导航 extra 传入本对象。
final class WebPageConfig {
  const WebPageConfig({
    required this.url,
    this.title,
    this.allowedHosts = const <String>[],
    this.headers = const <String, String>{},
    this.javaScriptMode = JavaScriptMode.unrestricted,
    this.userAgent,
    this.enableZoom = true,
    this.clearCacheOnOpen = false,
    this.clearLocalStorageOnOpen = false,
    this.showProgress = true,
    this.showToolbarActions = true,
    this.showCloseButton = true,
    this.enableWebHistoryBack = true,
    this.method = LoadRequestMethod.get,
    this.body,
  });

  final String url;
  final String? title;
  final List<String> allowedHosts;
  final Map<String, String> headers;
  final JavaScriptMode javaScriptMode;
  final String? userAgent;
  final bool enableZoom;
  final bool clearCacheOnOpen;
  final bool clearLocalStorageOnOpen;
  final bool showProgress;
  final bool showToolbarActions;
  final bool showCloseButton;
  final bool enableWebHistoryBack;
  final LoadRequestMethod method;
  final Uint8List? body;

  static WebPageConfig fromRouteState({
    required Map<String, String> queryParameters,
    Object? extra,
  }) {
    if (extra is WebPageConfig) {
      return extra;
    }
    return WebPageConfig(
      url: queryParameters['url'] ?? '',
      title: queryParameters['title'],
    );
  }

  Uri? get uri => normalizeWebUri(url);

  bool get isValidUrl => uri != null;

  bool get isHostAllowed {
    final parsed = uri;
    if (parsed == null) return false;
    return isAllowedHost(parsed, allowedHosts);
  }

  bool get canLoad => isValidUrl && isHostAllowed;

  WebPageValidationResult validate() {
    final parsed = uri;
    if (parsed == null) {
      return WebPageValidationResult.invalidUrl;
    }
    if (!isAllowedHost(parsed, allowedHosts)) {
      return WebPageValidationResult.blockedHost;
    }
    return WebPageValidationResult.ok;
  }

  static Uri? normalizeWebUri(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      return null;
    }
    final scheme = parsed.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return null;
    }
    return parsed;
  }

  static bool isAllowedHost(Uri uri, List<String> allowedHosts) {
    if (allowedHosts.isEmpty) return true;
    final host = uri.host.toLowerCase();
    return allowedHosts
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .any((allowedHost) => host == allowedHost);
  }
}

enum WebPageValidationResult { ok, invalidUrl, blockedHost }
