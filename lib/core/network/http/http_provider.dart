import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/env.dart';
import '../../../shared/services/auth/auth_manager.dart';
import '../../constant/duration_const.dart';
import '../../l10n/l10n.dart';
import 'config/http_auth_config.dart';
import 'config/http_config.dart';
import 'config/http_hint_config.dart';
import 'config/http_response_config.dart';
import 'config/http_security_config.dart';
import 'config/retry_policy.dart';
import 'http_client.dart';

// =============================================================================
// HTTP 配置 → 客户端 Provider 链
//
// 依赖流向：
//   appConfig (全局)
//     → httpConfigProvider    (不可变 HttpConfig)
//       → httpClientProvider  (HttpClient 实例)
//
// 可测试性：
//   ProviderScope.overrides → 替换任一 Provider 即可注入 Mock
// =============================================================================

/// HTTP 全局配置 Provider。
///
/// 从 [appConfig] 读取环境相关配置，生成不可变的 [HttpConfig]。
/// 仅 [appConfig] 变更时需要重建（通常只在 main 中设置一次）。
final httpConfigProvider = Provider<HttpConfig>((ref) {
  final baseUrl = appConfig.apiBaseUrl.trim();
  final proxyHost = _resolveProxyHost();
  final i18n = ref.watch(appLocalizationsProvider);

  return HttpConfig(
    baseUrl: baseUrl,
    connectTimeout: Duration(milliseconds: DurationConst.httpConnectTimeoutMs),
    receiveTimeout: Duration(milliseconds: DurationConst.httpReceiveTimeoutMs),
    sendTimeout: Duration(milliseconds: DurationConst.httpSendTimeoutMs),
    enableLogging: appConfig.httpLogEnable,
    enablePacketCapture: appConfig.proxyEnable && proxyHost != null,
    proxyHost: proxyHost,
    proxyPort: _resolveProxyPort(),
    allowBadCertificate: appConfig.httpAllowBadCertificate,
    securityConfig: HttpSecurityConfig(
      allowInvalidCertificates: appConfig.httpAllowBadCertificate,
    ),
    defaultRetryPolicy: appConfig.httpRetryEnable
        ? RetryPolicy(
            maxAttempts: DurationConst.httpRetryCount,
            delay: DurationConst.httpRetryDelay,
          )
        : const RetryPolicy(maxAttempts: 0),
    responseConfig: HttpResponseConfig(
      enableBusinessStatusCheck: appConfig.httpBusinessStatusCheckEnable,
    ),
    hintConfig: HttpHintConfig(
      networkErrorHint: i18n.networkErrorHint,
      serverErrorHint: i18n.serverErrorHint,
      unknownHint: i18n.unknownHint,
      timeoutHint: i18n.timeoutHint,
      reqErrorHint: i18n.reqErrorHint,
      dataParseHint: i18n.dataParseHint,
    ),
    authConfig: HttpAuthConfig(
      headerMapProvider: () async {
        final headers = <String, dynamic>{
          'X-App-Channel': 'flutter_starter_app',
          'X-App-Env': appConfig.envTag.name,
        };
        final token = authManager.bearerToken;
        if (token != null) {
          headers['Authorization'] = token;
        }
        return headers;
      },
    ),
  );
});

/// HTTP 客户端 Provider。
///
/// ## 依赖
/// - [httpConfigProvider] — 连接、超时、日志、重试等配置
/// - [AuthSessionStore] — 请求头中的 token 由 [AuthInterceptor] 在拦截器中懒读取
///
/// ## 覆盖
/// 在 [ProviderScope.overrides] 中注入 env 专属配置或 Mock：
/// ```dart
/// httpClientProvider.overrideWith((ref) => MockHttpClient())
/// ```
final httpClientProvider = Provider<HttpClient>((ref) {
  final config = ref.watch(httpConfigProvider);
  // 注意：AuthSessionStore 在请求时由 AuthInterceptor 懒读取，不在此处 watch
  return HttpClient(config: config);
});

// ---------------------------------------------------------------------------
// 代理解析（从 EnvConfig 提取）
// ---------------------------------------------------------------------------

String? _resolveProxyHost() {
  if (!appConfig.proxyEnable) return null;
  final raw = appConfig.caughtAddress?.trim();
  if (raw == null || raw.isEmpty) return null;
  return raw.split(':').first.trim();
}

int _resolveProxyPort() {
  if (!appConfig.proxyEnable) return 8888;
  final raw = appConfig.caughtAddress?.trim();
  if (raw == null || raw.isEmpty) return 8888;
  final parts = raw.split(':');
  if (parts.length < 2) return 8888;
  return int.tryParse(parts.last.trim()) ?? 8888;
}
