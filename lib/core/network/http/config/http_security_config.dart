/// HTTPS 证书校验配置。
class HttpSecurityConfig {
  const HttpSecurityConfig({
    this.allowInvalidCertificates = false,
    this.validateCertificate,
  });

  /// 是否允许自签名或无效证书。
  final bool allowInvalidCertificates;

  /// 自定义证书校验回调。
  final bool Function(Object certificate, String host, int port)?
      validateCertificate;

  /// 复制并覆盖部分字段。
  HttpSecurityConfig copyWith({
    bool? allowInvalidCertificates,
    bool Function(Object certificate, String host, int port)?
        validateCertificate,
  }) {
    return HttpSecurityConfig(
      allowInvalidCertificates:
          allowInvalidCertificates ?? this.allowInvalidCertificates,
      validateCertificate: validateCertificate ?? this.validateCertificate,
    );
  }
}
