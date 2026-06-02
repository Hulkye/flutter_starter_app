/// 动态 Header 注入器的签名（例如 token、设备信息）。
typedef HeaderMapProvider = Future<Map<String, dynamic>?> Function();

/// 认证失败回调的签名。
typedef AuthFailedCallback = Future<void> Function();

/// 认证配置。
///
/// 驱动内置的 [AuthInterceptor]；传入 [HttpClient] 后，
/// 每次请求自动注入动态 Header，401 响应自动触发 [onAuthFailed] 回调。
class HttpAuthConfig {
  const HttpAuthConfig({
    this.headerMapProvider,
    this.onAuthFailed,
    this.overrideIfHeaderExists = false,
  });

  /// 异步返回需要注入的 Header（如 Bearer token）。
  final HeaderMapProvider? headerMapProvider;

  /// 服务端返回 401 或业务状态检查判定 Token 过期时调用。
  final AuthFailedCallback? onAuthFailed;

  /// 为 `true` 时，[headerMapProvider] 返回的 Header 会覆盖
  /// 请求中已存在的同名 Header。
  final bool overrideIfHeaderExists;

  HttpAuthConfig copyWith({
    HeaderMapProvider? headerMapProvider,
    AuthFailedCallback? onAuthFailed,
    bool? overrideIfHeaderExists,
  }) {
    return HttpAuthConfig(
      headerMapProvider: headerMapProvider ?? this.headerMapProvider,
      onAuthFailed: onAuthFailed ?? this.onAuthFailed,
      overrideIfHeaderExists:
          overrideIfHeaderExists ?? this.overrideIfHeaderExists,
    );
  }
}
