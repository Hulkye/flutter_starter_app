import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../error/http_exception.dart';
import '../request/http_request.dart';
import '../response/http_response.dart';

/// HTTP 日志抽象 —— 支持注入自定义实现（如写入文件、上报远程）。
abstract class HttpLogger {
  const HttpLogger();

  /// 记录请求。
  void logRequest(HttpRequest<dynamic> request);

  /// 记录响应。
  void logResponse(HttpRequest<dynamic> request, HttpResponse<dynamic> response);

  /// 记录错误。
  void logError(HttpRequest<dynamic> request, Object error);

  /// 记录重试。
  void logRetry(
    HttpRequest<dynamic> request, {
    required Object error,
    required int retryCount,
    required Duration delay,
    required Duration elapsed,
    int? statusCode,
  });

  /// 记录缓存命中。
  void logCacheHit(HttpRequest<dynamic> request, {int? statusCode});
}

/// 基于 package:logger 的默认日志实现（仅在 debug 模式输出）。
class DefaultHttpLogger extends HttpLogger {
  DefaultHttpLogger();

  final Logger _logger = Logger();

  @override
  void logRequest(HttpRequest<dynamic> request) {
    if (!kDebugMode) return;
    _logger.d('HTTP ${request.method.name.toUpperCase()} ${request.path}');
  }

  @override
  void logResponse(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response,
  ) {
    if (!kDebugMode) return;
    final durationMs = response.extra['durationMs'];
    final retryCount = response.extra['retryCount'] ?? 0;
    final fromMock = response.extra['fromMock'] == true;
    _logger.i(
      'HTTP ${request.method.name.toUpperCase()} ${request.path} '
      '=> ${response.statusCode} '
      '(耗时: ${durationMs ?? '-'}ms, 重试: $retryCount, '
      '缓存: ${response.fromCache}, Mock: $fromMock)',
    );
  }

  @override
  void logError(HttpRequest<dynamic> request, Object error) {
    if (!kDebugMode) return;
    final statusCode = error is HttpException ? error.statusCode : null;
    final type = error is HttpException ? error.type.name : error.runtimeType;
    _logger.e(
      'HTTP ${request.method.name.toUpperCase()} ${request.path} 失败 '
      '(状态码: ${statusCode ?? '-'}, 类型: $type)',
      error: error,
    );
  }

  @override
  void logRetry(
    HttpRequest<dynamic> request, {
    required Object error,
    required int retryCount,
    required Duration delay,
    required Duration elapsed,
    int? statusCode,
  }) {
    if (!kDebugMode) return;
    _logger.w(
      'HTTP ${request.method.name.toUpperCase()} ${request.path} '
      '第${retryCount}次重试，等待${delay.inMilliseconds}ms '
      '(已耗时: ${elapsed.inMilliseconds}ms, 状态码: ${statusCode ?? '-'})',
      error: error,
    );
  }

  @override
  void logCacheHit(HttpRequest<dynamic> request, {int? statusCode}) {
    if (!kDebugMode) return;
    _logger.i(
      'HTTP ${request.method.name.toUpperCase()} ${request.path} '
      '缓存命中 (状态码: ${statusCode ?? '-'})',
    );
  }
}
