import 'dart:convert';

import '../request/http_request.dart';
import 'serialization_utils.dart';

/// 缓存键构建函数类型。
typedef CacheKeyBuilder = String Function(dynamic request);

/// 参与缓存键变化的默认 Vary 头集合。
const Set<String> _defaultVaryHeaders = <String>{
  'accept',
  'accept-language',
  'content-type',
};

/// 规范化请求路径（参数排序，避免顺序影响缓存键）。
String _normalizePath(String path) {
  final uri = Uri.tryParse(path);
  if (uri == null) return path;
  if (!uri.hasQuery) return path;
  return uri
      .replace(queryParameters: _normalizeQuery(uri.queryParametersAll))
      .toString();
}

/// 查询参数字母序排列。
Map<String, dynamic>? _normalizeQuery(Map<String, dynamic>? queryParameters) {
  if (queryParameters == null || queryParameters.isEmpty) return null;
  final sortedKeys = queryParameters.keys.map((k) => k.toString()).toList()
    ..sort();
  return <String, dynamic>{
    for (final key in sortedKeys) key: _normalizeValue(queryParameters[key]),
  };
}

/// 仅保留影响响应的 Header（Vary 头）。
Map<String, dynamic>? _normalizeHeaders(Map<String, String>? headers) {
  if (headers == null || headers.isEmpty) return null;
  final normalized = <String, String>{};
  for (final entry in headers.entries) {
    final key = entry.key.toLowerCase().trim();
    if (_defaultVaryHeaders.contains(key)) {
      normalized[key] = entry.value.trim();
    }
  }
  if (normalized.isEmpty) return null;
  final sortedKeys = normalized.keys.toList()..sort();
  return <String, dynamic>{for (final key in sortedKeys) key: normalized[key]};
}

/// 递归规范化任意值。
dynamic _normalizeValue(dynamic value) {
  final jsonFriendly = encodeJsonFriendly(value);
  if (jsonFriendly is Map) {
    final sortedKeys = jsonFriendly.keys.map((k) => k.toString()).toList()
      ..sort();
    return <String, dynamic>{
      for (final key in sortedKeys) key: _normalizeValue(jsonFriendly[key]),
    };
  }
  if (jsonFriendly is List) {
    return jsonFriendly.map(_normalizeValue).toList();
  }
  return jsonFriendly;
}

/// 默认缓存键生成器 —— 将请求的关键字段序列化为稳定的 JSON 字符串。
String defaultCacheKeyBuilder(HttpRequest<dynamic> request) {
  return jsonEncode(<String, dynamic>{
    'method': request.method.name.toUpperCase(),
    'path': _normalizePath(request.path),
    'queryParameters': _normalizeQuery(request.queryParameters),
    'headers': _normalizeHeaders(request.headers),
    'data': _normalizeValue(request.data),
    'extra': _normalizeValue(request.extra),
  });
}
