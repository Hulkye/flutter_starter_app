import 'package:dio/dio.dart';

import '../config/retry_policy.dart';
import '../enum/cache_policy.dart';
import '../enum/http_method.dart';

/// 泛型 HTTP 请求模型 —— 一等公民。
///
/// 承载请求所需的全部信息：方法、路径、Header、请求体、超时、缓存策略、
/// 重试策略、解析器等。字段为 `null` 时自动继承 [HttpConfig] 中的全局默认值。
class HttpRequest<T> {
  const HttpRequest({
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
    this.headers,
    this.cancelToken,
    this.responseType,
    this.connectTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.followRedirects,
    this.receiveDataWhenStatusError,
    this.validateStatus,
    this.loggingEnabled,
    this.cachePolicy = CachePolicy.noCache,
    this.cacheTtl,
    this.retryPolicy,
    this.parser,
    this.onSendProgress,
    this.onReceiveProgress,
    this.extra,
  });

  /// HTTP 方法。
  final HttpMethod method;

  /// 请求路径（相对于 baseUrl）。
  final String path;

  /// 请求体数据。
  final dynamic data;

  /// URL 查询参数。
  final Map<String, dynamic>? queryParameters;

  /// 单次请求 Header（与全局 Header 合并）。
  final Map<String, String>? headers;

  /// 取消令牌。
  final CancelToken? cancelToken;

  /// 期望的响应类型。
  final ResponseType? responseType;

  /// 单次请求连接超时。
  final Duration? connectTimeout;

  /// 单次请求接收超时。
  final Duration? receiveTimeout;

  /// 单次请求发送超时。
  final Duration? sendTimeout;

  /// 是否自动跟随 HTTP 重定向。
  final bool? followRedirects;

  /// 状态码异常时是否仍接收响应数据。
  final bool? receiveDataWhenStatusError;

  /// 自定义状态码校验函数。
  final bool Function(int? statusCode)? validateStatus;

  /// 单次请求日志开关。
  final bool? loggingEnabled;

  /// 缓存策略（仅 GET 请求生效）。
  final CachePolicy cachePolicy;

  /// 单次请求缓存有效期。
  final Duration? cacheTtl;

  /// 单次请求重试策略（覆盖全局默认值）。
  final RetryPolicy? retryPolicy;

  /// 响应解析器 —— 将原始数据转换为泛型 [T]。
  final T Function(dynamic data)? parser;

  /// 上传进度回调。
  final ProgressCallback? onSendProgress;

  /// 下载进度回调。
  final ProgressCallback? onReceiveProgress;

  /// 扩展字段（也用于单请求级别覆盖，如 `_check_business_status`）。
  final Map<String, dynamic>? extra;

  /// 不可变复制，仅覆盖指定字段。
  HttpRequest<T> copyWith({
    HttpMethod? method,
    String? path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    CachePolicy? cachePolicy,
    Duration? cacheTtl,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? extra,
  }) {
    return HttpRequest<T>(
      method: method ?? this.method,
      path: path ?? this.path,
      data: data ?? this.data,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      cancelToken: cancelToken ?? this.cancelToken,
      responseType: responseType ?? this.responseType,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      receiveDataWhenStatusError:
          receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      validateStatus: validateStatus ?? this.validateStatus,
      loggingEnabled: loggingEnabled ?? this.loggingEnabled,
      cachePolicy: cachePolicy ?? this.cachePolicy,
      cacheTtl: cacheTtl ?? this.cacheTtl,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      parser: parser ?? this.parser,
      onSendProgress: onSendProgress ?? this.onSendProgress,
      onReceiveProgress: onReceiveProgress ?? this.onReceiveProgress,
      extra: extra ?? this.extra,
    );
  }
}
