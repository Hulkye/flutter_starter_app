/// 当前环境的 Deep Link 配置。
final class DeepLinkConfig {
  const DeepLinkConfig({required this.appScheme, required this.appLinkHost});

  /// App 自定义 URL Scheme。
  final String appScheme;

  /// Universal Links 和 Android App Links 关联 host。
  final String appLinkHost;

  factory DeepLinkConfig.fromJson(Map<String, dynamic> json) {
    final appScheme = json['appScheme'];
    final appLinkHost = json['appLinkHost'];
    if (appScheme is! String || appLinkHost is! String) {
      throw const FormatException('Deep link scheme and host are required.');
    }
    if (appScheme.trim().isEmpty || appLinkHost.trim().isEmpty) {
      throw const FormatException('Deep link scheme and host cannot be empty.');
    }
    return DeepLinkConfig(appScheme: appScheme, appLinkHost: appLinkHost);
  }
}
