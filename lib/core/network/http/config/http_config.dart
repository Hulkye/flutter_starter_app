import 'package:dio/dio.dart';

import '../enum/cache_policy.dart';
import '../shared/http_cache_key_builder.dart';
import 'http_auth_config.dart';
import 'http_hint_config.dart';
import 'http_response_config.dart';
import 'http_security_config.dart';
import 'retry_policy.dart';

/// 集中式、不可变的 HTTP 全局配置。
///
/// 每个字段均可通过 [HttpRequest] 在单次请求中覆盖；所有"全局默认值"
/// 均集中于此。同时，该类也是唯一负责生成 Dio [BaseOptions] 的地方，
/// 将 Dio 相关的转换收敛在一个文件内。
class HttpConfig {
  const HttpConfig({
    this.baseUrl = '',
    this.headers = const <String, String>{},
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.sendTimeout = const Duration(seconds: 15),
    this.followRedirects = true,
    this.receiveDataWhenStatusError = true,
    this.defaultCachePolicy = CachePolicy.noCache,
    this.defaultCacheTtl = const Duration(minutes: 5),
    this.defaultRetryPolicy,
    this.enableLogging = true,
    this.enableMock = false,
    this.securityConfig = const HttpSecurityConfig(),
    this.cacheKeyBuilder,
    this.userAgent,
    this.validateStatus,
    // --- 调试 & 业务状态 --------------------------------------------------
    this.enablePacketCapture = false,
    this.proxyHost,
    this.proxyPort = 8888,
    this.allowBadCertificate = false,
    this.responseConfig = const HttpResponseConfig(),
    this.authConfig,
    this.hintConfig,
  });

  // -----------------------------------------------------------------------
  // 基础网络配置
  // -----------------------------------------------------------------------

  /// 基础地址，所有请求路径之前自动拼接。
  final String baseUrl;

  /// 每次请求默认携带的 Header。
  final Map<String, String> headers;

  /// 连接超时。
  final Duration connectTimeout;

  /// 接收超时。
  final Duration receiveTimeout;

  /// 发送超时。
  final Duration sendTimeout;

  /// 是否自动跟随 HTTP 重定向。
  final bool followRedirects;

  /// 状态码异常时是否仍接收响应数据。
  final bool receiveDataWhenStatusError;

  /// GET 请求的默认缓存策略。
  final CachePolicy defaultCachePolicy;

  /// 缓存条目的默认有效期。
  final Duration defaultCacheTtl;

  /// 默认重试策略（null = 不重试）。
  final RetryPolicy? defaultRetryPolicy;

  /// 全局日志开关。
  final bool enableLogging;

  /// 全局 Mock 开关。
  final bool enableMock;

  /// SSL / 证书校验配置。
  final HttpSecurityConfig securityConfig;

  /// 自定义缓存键生成器。
  final CacheKeyBuilder? cacheKeyBuilder;

  /// User-Agent 头的内容。
  final String? userAgent;

  /// 可选的状态码校验回调。
  final bool Function(int? statusCode)? validateStatus;

  // -----------------------------------------------------------------------
  // 调试、代理与业务功能
  // -----------------------------------------------------------------------

  /// 是否启用内置抓包拦截器的事件回调。
  final bool enablePacketCapture;

  /// 代理主机（用于 Charles / Proxyman / mitm 抓包调试）。
  final String? proxyHost;

  /// 代理端口（默认 8888）。
  final int proxyPort;

  /// 是否接受自签名证书（通常与代理配套使用）。
  final bool allowBadCertificate;

  /// 业务状态码信封配置。
  ///
  /// 非 null 时自动安装 [BusinessStatusInterceptor]，
  /// 对每个响应进行解包和校验。
  final HttpResponseConfig responseConfig;

  /// 认证配置。
  ///
  /// 非 null 时自动安装 [AuthInterceptor]。
  final HttpAuthConfig? authConfig;

  /// 用户可见错误提示文案覆盖。
  final HttpHintConfig? hintConfig;

  // -----------------------------------------------------------------------
  // Dio 桥接（Dio Options 的唯一生成点）
  // -----------------------------------------------------------------------

  BaseOptions toBaseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      headers: headers,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      followRedirects: followRedirects,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      validateStatus: validateStatus,
    );
  }

  // -----------------------------------------------------------------------
  // Copy
  // -----------------------------------------------------------------------

  HttpConfig copyWith({
    String? baseUrl,
    Map<String, String>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    CachePolicy? defaultCachePolicy,
    Duration? defaultCacheTtl,
    RetryPolicy? defaultRetryPolicy,
    bool? enableLogging,
    bool? enableMock,
    HttpSecurityConfig? securityConfig,
    CacheKeyBuilder? cacheKeyBuilder,
    String? userAgent,
    bool Function(int? statusCode)? validateStatus,
    bool? enablePacketCapture,
    String? proxyHost,
    int? proxyPort,
    bool? allowBadCertificate,
    HttpResponseConfig? responseConfig,
    HttpAuthConfig? authConfig,
    HttpHintConfig? hintConfig,
  }) {
    return HttpConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      headers: headers ?? this.headers,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      receiveDataWhenStatusError:
          receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      defaultCachePolicy: defaultCachePolicy ?? this.defaultCachePolicy,
      defaultCacheTtl: defaultCacheTtl ?? this.defaultCacheTtl,
      defaultRetryPolicy: defaultRetryPolicy ?? this.defaultRetryPolicy,
      enableLogging: enableLogging ?? this.enableLogging,
      enableMock: enableMock ?? this.enableMock,
      securityConfig: securityConfig ?? this.securityConfig,
      cacheKeyBuilder: cacheKeyBuilder ?? this.cacheKeyBuilder,
      userAgent: userAgent ?? this.userAgent,
      validateStatus: validateStatus ?? this.validateStatus,
      enablePacketCapture: enablePacketCapture ?? this.enablePacketCapture,
      proxyHost: proxyHost ?? this.proxyHost,
      proxyPort: proxyPort ?? this.proxyPort,
      allowBadCertificate: allowBadCertificate ?? this.allowBadCertificate,
      responseConfig: responseConfig ?? this.responseConfig,
      authConfig: authConfig ?? this.authConfig,
      hintConfig: hintConfig ?? this.hintConfig,
    );
  }
}
