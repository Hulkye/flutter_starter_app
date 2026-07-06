import 'dart:ui';

enum EnvTag {
  dev, // 开发环境
  sit, // 测试环境
  prod, // 生产环境
}

class EnvConfig {
  /// 环境标识
  final EnvTag envTag;

  /// UI设计稿的屏幕尺寸，单位为逻辑像素（dp）
  final Size uiScreenSize;

  /// 域名
  final String baseUrl;

  /// API 根路径（与 [baseUrl] 拼接），须以 `/` 开头，例如 `/api`。
  final String apiPathPrefix;

  /// 是否开启抓包
  final bool proxyEnable;

  /// 抓包工具的代理地址 + 端口
  final String? caughtAddress;

  /// 是否输出网络日志
  final bool httpLogEnable;

  /// 是否开启重试
  final bool httpRetryEnable;

  /// 是否启用业务状态码校验
  final bool httpBusinessStatusCheckEnable;

  /// 是否允许抓包时跳过证书校验（仅建议 dev/sit 使用）
  final bool httpAllowBadCertificate;

  /// 隐私政策URL
  final String privacyPolicyUrl;

  /// 用户协议URL
  final String userAgreementUrl;

  const EnvConfig({
    this.envTag = EnvTag.dev,
    this.uiScreenSize = const Size(402, 786),
    this.baseUrl = '',
    this.apiPathPrefix = '/api',
    this.proxyEnable = false,
    this.caughtAddress,
    bool? httpLogEnable,
    bool? httpRetryEnable,
    bool? httpBusinessStatusCheckEnable,
    bool? httpAllowBadCertificate,
    this.privacyPolicyUrl = '',
    this.userAgreementUrl = '',
  }) : httpLogEnable = httpLogEnable ?? envTag != EnvTag.prod,
       httpRetryEnable = httpRetryEnable ?? true,
       httpBusinessStatusCheckEnable = httpBusinessStatusCheckEnable ?? false,
       httpAllowBadCertificate = httpAllowBadCertificate ?? false;

  String get apiBaseUrl {
    final normalizedBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final normalizedPrefix = apiPathPrefix.trim();
    if (normalizedBaseUrl.isEmpty) {
      return normalizedPrefix;
    }
    if (normalizedPrefix.isEmpty || normalizedPrefix == '/') {
      return normalizedBaseUrl;
    }
    return '$normalizedBaseUrl${normalizedPrefix.startsWith('/') ? normalizedPrefix : '/$normalizedPrefix'}';
  }

  EnvConfig copyWith({
    EnvTag? envTag,
    Size? uiScreenSize,
    String? baseUrl,
    String? apiPathPrefix,
    bool? proxyEnable,
    String? caughtAddress,
    bool? httpLogEnable,
    bool? httpRetryEnable,
    bool? httpBusinessStatusCheckEnable,
    bool? httpAllowBadCertificate,
    String? privacyPolicyUrl,
    String? userAgreementUrl,
  }) {
    return EnvConfig(
      envTag: envTag ?? this.envTag,
      uiScreenSize: uiScreenSize ?? this.uiScreenSize,
      baseUrl: baseUrl ?? this.baseUrl,
      apiPathPrefix: apiPathPrefix ?? this.apiPathPrefix,
      proxyEnable: proxyEnable ?? this.proxyEnable,
      caughtAddress: caughtAddress ?? this.caughtAddress,
      httpLogEnable: httpLogEnable ?? this.httpLogEnable,
      httpRetryEnable: httpRetryEnable ?? this.httpRetryEnable,
      httpBusinessStatusCheckEnable:
          httpBusinessStatusCheckEnable ?? this.httpBusinessStatusCheckEnable,
      httpAllowBadCertificate:
          httpAllowBadCertificate ?? this.httpAllowBadCertificate,
      privacyPolicyUrl: privacyPolicyUrl ?? this.privacyPolicyUrl,
      userAgreementUrl: userAgreementUrl ?? this.userAgreementUrl,
    );
  }
}

EnvConfig appConfig = const EnvConfig();
