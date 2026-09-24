/// Deep Link 允许使用的应用 Scheme 和 App Link host。
final class DeepLinkConfig {
  const DeepLinkConfig({required this.appScheme, required this.appLinkHost});

  /// 自定义 Scheme，例如 `starter`。
  final String appScheme;

  /// Universal Links 或 Android App Links 关联的 host。
  final String appLinkHost;

  /// 从环境配置 JSON 读取并校验 Deep Link 配置。
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
