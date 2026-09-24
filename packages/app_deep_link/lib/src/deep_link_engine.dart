import 'dart:async';

import 'app_links_source.dart';
import 'deep_link_config.dart';
import 'deep_link_resolution.dart';
import 'deep_link_route.dart';
import 'deep_link_source.dart';

/// 独立 Deep Link 解析和平台事件协调器。
///
/// 只负责 URI 来源、安全校验和通用路由匹配，不负责宿主认证、页面导航
/// 或 WebView 策略。
final class DeepLinkEngine {
  DeepLinkEngine({
    required this.config,
    required this.routes,
    DeepLinkUriSource? source,
  }) : _source = source ?? AppLinksSource();

  /// 当前环境允许的来源配置。
  final DeepLinkConfig config;

  /// 宿主明确开放的 Deep Link 路由。
  final List<DeepLinkRoute> routes;

  /// 平台 URI 来源；默认使用 `app_links`，测试时可注入替代实现。
  final DeepLinkUriSource _source;

  StreamSubscription<Uri>? _subscription;
  bool _started = false;
  bool _disposed = false;
  bool _initialUriResolved = false;
  final List<Uri> _queuedUris = <Uri>[];
  String? _lastUri;

  /// 将单个 URI 转换为已校验的通用解析结果。
  DeepLinkResolution resolve(Uri? uri) {
    if (uri == null || uri.toString().trim().isEmpty) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.invalidUri);
    }
    if (uri.userInfo.isNotEmpty || uri.fragment.isNotEmpty) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.unsafeUri);
    }

    final source = _resolveSource(uri);
    if (source == null) {
      final scheme = uri.scheme.toLowerCase();
      return DeepLinkInvalid(
        scheme == 'http' || scheme == 'https'
            ? DeepLinkInvalidReason.blockedHost
            : DeepLinkInvalidReason.unsupportedScheme,
      );
    }

    final route = routes.cast<DeepLinkRoute?>().firstWhere(
      (candidate) => candidate!.path == uri.path,
      orElse: () => null,
    );
    if (route == null) {
      return const DeepLinkInvalid(DeepLinkInvalidReason.unknownPath);
    }

    return DeepLinkAccepted(
      DeepLinkMatch(
        route: route,
        source: source,
        queryParameters: _readQuery(uri.queryParametersAll),
      ),
    );
  }

  /// 先处理冷启动 URI，再订阅后续 URI 事件。
  Future<void> start(
    void Function(DeepLinkResolution resolution) onResolution,
  ) async {
    if (_started || _disposed) return;
    _started = true;

    _subscription = _source.uriStream.listen(
      (uri) {
        if (_initialUriResolved) {
          _handle(uri, onResolution);
        } else {
          _queuedUris.add(uri);
        }
      },
    );
    final initialUri = await _source.getInitialUri();
    if (_disposed) return;
    _handle(initialUri, onResolution);
    _initialUriResolved = true;
    for (final uri in _queuedUris) {
      _handle(uri, onResolution);
    }
    _queuedUris.clear();
  }

  /// 停止监听并释放平台来源。
  Future<void> dispose() async {
    _disposed = true;
    _queuedUris.clear();
    await _subscription?.cancel();
    _subscription = null;
    await _source.dispose();
  }

  /// 只接受配置的自定义 Scheme 或 App Link host。
  DeepLinkSourceKind? _resolveSource(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final configuredScheme = config.appScheme.trim().toLowerCase();
    if (configuredScheme.isNotEmpty && scheme == configuredScheme) {
      return uri.host.isEmpty ? DeepLinkSourceKind.appScheme : null;
    }
    if (scheme != 'http' && scheme != 'https') return null;
    return _matchesHost(uri.host, config.appLinkHost)
        ? DeepLinkSourceKind.appLink
        : null;
  }

  /// 标准化 host 的大小写和末尾点后进行比较。
  bool _matchesHost(String actual, String expected) {
    String normalize(String host) {
      final normalized = host.trim().toLowerCase();
      return normalized.endsWith('.')
          ? normalized.substring(0, normalized.length - 1)
          : normalized;
    }

    return normalize(actual) == normalize(expected);
  }

  /// 对重复 URI 去重后交给解析器和宿主回调。
  void _handle(
    Uri? uri,
    void Function(DeepLinkResolution resolution) onResolution,
  ) {
    if (uri == null || uri.toString() == _lastUri) return;
    _lastUri = uri.toString();
    onResolution(resolve(uri));
  }

  Map<String, String> _readQuery(Map<String, List<String>> parameters) {
    return <String, String>{
      for (final entry in parameters.entries) entry.key: entry.value.first,
    };
  }
}
