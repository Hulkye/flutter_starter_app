import '../request/http_request.dart';

/// 批量请求定义 —— 支持标准 [HttpRequest] 和自定义执行闭包。
class NetworkBatchRequest<T> {
  const NetworkBatchRequest.request(this.request) : execute = null;

  const NetworkBatchRequest.execute(this.execute) : request = null;

  /// 标准请求（走统一请求链路）。
  final HttpRequest<T>? request;

  /// 自定义执行闭包（不走统一链路）。
  final Future<T> Function()? execute;

  /// 是否为标准 HTTP 请求。
  bool get isRequest => request != null;
}
