import '../request/http_request.dart';

/// Mock 响应定义。
class HttpMockResponse<T> {
  const HttpMockResponse({
    required this.data,
    this.statusCode = 200,
    this.headers = const <String, List<String>>{},
    this.extra = const <String, dynamic>{},
    this.delay,
  });

  /// Mock 返回的数据。
  final T data;

  /// HTTP 状态码。
  final int statusCode;

  /// 响应头。
  final Map<String, List<String>> headers;

  /// 扩展字段。
  final Map<String, dynamic> extra;

  /// 模拟延迟（用于测试 loading 状态等）。
  final Duration? delay;
}

/// Mock 适配器抽象 —— 实现此接口来接管特定请求的响应。
///
/// 用法示例：
/// ```dart
/// class MyMock extends HttpMockAdapter {
///   bool matches(HttpRequest<dynamic> req) => req.path == '/api/user';
///   Future<HttpMockResponse<dynamic>?> resolve(HttpRequest<dynamic> req) async =>
///       HttpMockResponse(data: {'name': 'test'});
/// }
/// ```
abstract class HttpMockAdapter {
  const HttpMockAdapter();

  /// 判断是否命中此 Mock。
  bool matches(HttpRequest<dynamic> request);

  /// 返回 Mock 响应，null 表示不拦截（走真实网络）。
  Future<HttpMockResponse<dynamic>?> resolve(HttpRequest<dynamic> request);
}
