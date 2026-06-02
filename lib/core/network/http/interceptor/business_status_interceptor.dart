import '../config/http_auth_config.dart';
import '../config/http_hint_config.dart';
import '../config/http_response_config.dart';
import '../enum/http_error_type.dart';
import '../error/http_exception.dart';
import '../request/http_request.dart';
import '../response/http_response.dart';
import 'http_interceptor.dart';

/// 业务状态码拦截器 —— 自动解析后端统一响应信封。
///
/// 典型后端响应格式：
/// ```json
/// { "code": 0, "data": { ... }, "msg": "ok" }
/// ```
///
/// **响应阶段**：
/// 1. 从原始 body 中提取业务 code
/// 2. 成功 → 通过 [HttpResponseConfig.dataGetter] 提取 payload
/// 3. Token 过期 → 回调 [HttpAuthConfig.onAuthFailed] + 抛出 [HttpErrorType.unauthorized]
/// 4. 其他业务错误 → 抛出 [HttpErrorType.server]
///
/// 可通过 `HttpRequest.extra['_check_business_status'] = false`
/// 对单个请求关闭业务状态检查。
class BusinessStatusInterceptor extends HttpInterceptor {
  BusinessStatusInterceptor({
    required this.responseConfig,
    this.authConfig,
    this.hintConfig,
  });

  /// 业务状态检查配置（code / data / msg 提取规则）。
  final HttpResponseConfig responseConfig;

  /// 可选 —— Token 过期时触发的认证回调。
  final HttpAuthConfig? authConfig;

  /// 可选 —— 错误提示文案覆盖。
  final HttpHintConfig? hintConfig;

  /// 通过 extra 控制单请求是否跳过检查的 key。
  static const String _extraKey = '_check_business_status';

  @override
  Future<HttpResponse<dynamic>> onResponse(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response,
  ) async {
    // 支持单请求级别关闭
    final enabled =
        request.extra?[_extraKey] as bool? ??
        responseConfig.enableBusinessStatusCheck;
    if (!enabled) return response;

    final rawData = response.data;
    final code = responseConfig.codeGetter(rawData);

    if (code == null) {
      throw HttpException(
        type: HttpErrorType.parse,
        message: hintConfig?.dataParseHint ?? '响应 code 解析失败',
        data: rawData,
        request: request,
      );
    }

    // ---- 成功 -----------------------------------------------------------
    if (responseConfig.isSuccess(code, rawData)) {
      final payload = responseConfig.dataGetter(rawData);
      return HttpResponse<dynamic>(
        data: payload,
        statusCode: response.statusCode,
        headers: response.headers,
        extra: response.extra,
        fromCache: response.fromCache,
        requestOptions: response.requestOptions,
      );
    }

    // ---- Token 过期 ----------------------------------------------------
    final msg = responseConfig.msgGetter(rawData);
    if (responseConfig.isTokenExpired(code, rawData)) {
      await authConfig?.onAuthFailed?.call();
      throw HttpException(
        type: HttpErrorType.unauthorized,
        message: msg ?? hintConfig?.serverErrorHint ?? '登录凭证已过期',
        statusCode: response.statusCode,
        businessCode: code,
        data: rawData,
        request: request,
      );
    }

    // ---- 业务错误 -------------------------------------------------------
    throw HttpException(
      type: HttpErrorType.server,
      message: msg ?? hintConfig?.serverErrorHint ?? '服务端业务错误',
      statusCode: response.statusCode,
      businessCode: code,
      data: rawData,
      request: request,
    );
  }
}
