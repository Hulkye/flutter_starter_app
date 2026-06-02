import '../error/http_exception.dart';
import '../request/http_request.dart';
import '../response/http_response.dart';
import 'http_interceptor.dart';

/// 拦截器链执行器。
///
/// - **请求阶段**：按列表顺序依次执行（0 → n）。
/// - **响应 / 错误阶段**：按列表逆序依次执行（n → 0），形成洋葱模型。
class InterceptorChain {
  const InterceptorChain(this._interceptors);

  final List<HttpInterceptor> _interceptors;

  /// 顺序执行请求拦截。
  Future<HttpRequest<dynamic>> runRequest(HttpRequest<dynamic> request) async {
    var current = request;
    for (final interceptor in _interceptors) {
      current = await interceptor.onRequest(current);
    }
    return current;
  }

  /// 逆序执行响应拦截。
  Future<HttpResponse<dynamic>> runResponse(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response,
  ) async {
    var current = response;
    for (final interceptor in _interceptors.reversed) {
      current = await interceptor.onResponse(request, current);
    }
    return current;
  }

  /// 逆序执行错误拦截。
  Future<HttpException> runError(
    HttpRequest<dynamic> request,
    HttpException error,
  ) async {
    var current = error;
    for (final interceptor in _interceptors.reversed) {
      current = await interceptor.onError(request, current);
    }
    return current;
  }
}
