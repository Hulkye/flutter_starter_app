import '../config/http_auth_config.dart';
import '../enum/http_error_type.dart';
import '../error/http_exception.dart';
import '../request/http_request.dart';
import 'http_interceptor.dart';

/// 认证拦截器 —— 基于 [HttpAuthConfig] 自动注入动态 Header。
///
/// **请求阶段**：调用 [HttpAuthConfig.headerMapProvider] 获取最新 token /
/// 设备信息等，注入到请求 Header 中。
///
/// **错误阶段**：遇到 401 时自动触发 [HttpAuthConfig.onAuthFailed] 回调
///（如跳转登录页、刷新 token 等）。
class AuthInterceptor extends HttpInterceptor {
  AuthInterceptor(this.authConfig);

  final HttpAuthConfig authConfig;

  @override
  Future<HttpRequest<dynamic>> onRequest(HttpRequest<dynamic> request) async {
    final provider = authConfig.headerMapProvider;
    if (provider == null) return request;

    final extraHeaders = await provider();
    if (extraHeaders == null || extraHeaders.isEmpty) return request;

    final merged = <String, String>{...?request.headers};

    for (final entry in extraHeaders.entries) {
      final exists = merged.containsKey(entry.key);
      if (!exists || authConfig.overrideIfHeaderExists) {
        merged[entry.key] = entry.value.toString();
      }
    }

    return request.copyWith(headers: merged);
  }

  @override
  Future<HttpException> onError(
    HttpRequest<dynamic> request,
    HttpException error,
  ) async {
    if (error.type == HttpErrorType.unauthorized || error.statusCode == 401) {
      await authConfig.onAuthFailed?.call();
    }
    return error;
  }
}
