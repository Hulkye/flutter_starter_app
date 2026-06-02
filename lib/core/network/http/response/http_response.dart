import '../request/http_request.dart';

/// 泛型 HTTP 响应模型 —— 一等公民。
///
/// 承载反序列化后的响应体以及元数据（状态码、Header、耗时、缓存标记等），
/// 调用方无需接触 Dio 内部类型。
class HttpResponse<T> {
  const HttpResponse({
    required this.data,
    this.statusCode,
    this.headers = const <String, List<String>>{},
    this.extra = const <String, dynamic>{},
    this.fromCache = false,
    this.requestOptions,
  });

  /// 响应体（启用业务状态码检查时已由 [BusinessStatusInterceptor] 从信封中解包）。
  final T data;

  /// HTTP 状态码。
  final int? statusCode;

  /// 响应头。
  final Map<String, List<String>> headers;

  /// 扩展字段 —— 携带可观测性元数据：
  /// - `durationMs` (int) — 耗时
  /// - `retryCount` (int) — 重试次数
  /// - `fromMock` (bool) — 是否来自 Mock
  /// - `method` (String) — 请求方法
  /// - `path` (String) — 请求路径
  final Map<String, dynamic> extra;

  /// 是否来自本地缓存。
  final bool fromCache;

  /// 对应的请求信息（可用时）。
  final HttpRequest<dynamic>? requestOptions;

  /// 转换数据类型，同时保留元数据不变。
  HttpResponse<R> map<R>(R Function(T data) mapper) {
    return HttpResponse<R>(
      data: mapper(data),
      statusCode: statusCode,
      headers: headers,
      extra: extra,
      fromCache: fromCache,
      requestOptions: requestOptions,
    );
  }
}
