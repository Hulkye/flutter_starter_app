// --- 业务状态码信封解析的回调签名 -------------------------------------------

/// 从原始响应数据中提取业务状态码。
typedef RespCodeGetter = int? Function(dynamic raw);

/// 从原始响应数据中提取人类可读消息。
typedef RespMsgGetter = String? Function(dynamic raw);

/// 从原始响应数据中提取业务 payload。
typedef RespDataGetter = dynamic Function(dynamic raw);

/// 判断业务状态码是否代表成功。
typedef RespSuccessChecker = bool Function(int code, dynamic raw);

/// 判断业务状态码是否代表 Token 已过期。
typedef TokenExpiredChecker = bool Function(int code, dynamic raw);

// ---------------------------------------------------------------------------
// 配置
// ---------------------------------------------------------------------------

/// 驱动内置的 [BusinessStatusInterceptor]。
///
/// 大多数后端 API 使用标准信封包装响应：
/// ```json
/// { "code": 0, "data": { ... }, "msg": "ok" }
/// ```
///
/// [HttpResponseConfig] 让你一次性声明该信封格式，此后所有响应自动完成
/// 解包、校验，并在失败时映射为类型化异常。
class HttpResponseConfig {
  const HttpResponseConfig({
    this.enableBusinessStatusCheck = true,
    this.defaultSuccessCode = 0,
    this.codeGetter = _defaultCodeGetter,
    this.msgGetter = _defaultMsgGetter,
    this.dataGetter = _defaultDataGetter,
    this.successChecker,
    this.tokenExpiredChecker,
  });

  /// [BusinessStatusInterceptor] 是否生效。
  ///
  /// 可通过 `HttpRequest.extra['_check_business_status'] = false` 对单个请求关闭。
  final bool enableBusinessStatusCheck;

  /// 未提供自定义 [successChecker] 时视为成功的 code 值。
  final int defaultSuccessCode;

  /// 从原始响应体中提取业务状态码。
  final RespCodeGetter codeGetter;

  /// 从原始响应体中提取人类可读消息。
  final RespMsgGetter msgGetter;

  /// 从原始响应体中提取业务 payload。
  ///
  /// 此 getter 的返回值会成为下游拦截器和最终调用方拿到的 [HttpResponse.data]。
  final RespDataGetter dataGetter;

  /// 自定义成功判定。`null` 时默认比较 `code == defaultSuccessCode`。
  final RespSuccessChecker? successChecker;

  /// 自定义 Token 过期判定。返回 `true` 会触发
  /// [HttpAuthConfig.onAuthFailed] 回调并抛出
  /// [HttpErrorType.unauthorized] 异常。
  final TokenExpiredChecker? tokenExpiredChecker;

  // -----------------------------------------------------------------------
  // 拦截器内部使用的辅助方法
  // -----------------------------------------------------------------------

  bool isSuccess(int code, dynamic raw) {
    return successChecker?.call(code, raw) ?? code == defaultSuccessCode;
  }

  bool isTokenExpired(int code, dynamic raw) {
    return tokenExpiredChecker?.call(code, raw) ?? false;
  }

  // -----------------------------------------------------------------------
  // 默认实现 —— 假设 `{ code, data, msg }` 标准信封
  // -----------------------------------------------------------------------

  static int? _defaultCodeGetter(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final dynamic code = raw['code'] ?? raw['status'];
      if (code is int) return code;
      if (code is String) return int.tryParse(code);
    }
    return null;
  }

  static String? _defaultMsgGetter(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final dynamic msg = raw['msg'] ?? raw['message'];
      return msg?.toString();
    }
    return null;
  }

  static dynamic _defaultDataGetter(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['data'];
    }
    return raw;
  }

  // -----------------------------------------------------------------------
  // Copy
  // -----------------------------------------------------------------------

  HttpResponseConfig copyWith({
    bool? enableBusinessStatusCheck,
    int? defaultSuccessCode,
    RespCodeGetter? codeGetter,
    RespMsgGetter? msgGetter,
    RespDataGetter? dataGetter,
    RespSuccessChecker? successChecker,
    TokenExpiredChecker? tokenExpiredChecker,
  }) {
    return HttpResponseConfig(
      enableBusinessStatusCheck:
          enableBusinessStatusCheck ?? this.enableBusinessStatusCheck,
      defaultSuccessCode: defaultSuccessCode ?? this.defaultSuccessCode,
      codeGetter: codeGetter ?? this.codeGetter,
      msgGetter: msgGetter ?? this.msgGetter,
      dataGetter: dataGetter ?? this.dataGetter,
      successChecker: successChecker ?? this.successChecker,
      tokenExpiredChecker: tokenExpiredChecker ?? this.tokenExpiredChecker,
    );
  }
}
