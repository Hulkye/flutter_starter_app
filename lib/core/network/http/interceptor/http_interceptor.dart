import '../error/http_exception.dart';
import '../request/http_request.dart';
import '../response/http_response.dart';

/// HTTP 拦截器抽象 —— 与底层 HTTP 库（Dio）完全解耦。
///
/// 使用者实现此接口来插入自定义逻辑，无需依赖 Dio 类型。
/// 内置提供了 [AuthInterceptor]、[BusinessStatusInterceptor]、
/// [PacketCaptureInterceptor]、[ExceptionCaptureInterceptor] 等开箱即用的实现。
abstract class HttpInterceptor {
  const HttpInterceptor();

  /// 请求阶段拦截 —— 按注册顺序执行。
  ///
  /// 可在此修改请求参数、注入 Header、记录日志等。
  Future<HttpRequest<dynamic>> onRequest(HttpRequest<dynamic> request) async =>
      request;

  /// 响应阶段拦截 —— 按注册逆序执行。
  ///
  /// 可在此校验业务状态码、转换数据格式等。
  Future<HttpResponse<dynamic>> onResponse(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response,
  ) async => response;

  /// 错误阶段拦截 —— 按注册逆序执行。
  ///
  /// 可在此统一处理异常、上报埋点、转换错误类型等。
  Future<HttpException> onError(
    HttpRequest<dynamic> request,
    HttpException error,
  ) async => error;
}
