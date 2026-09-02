import '../../../core/navigation/app_navigation_command.dart';

/// 深链来源类型。
enum DeepLinkSource {
  /// App 自定义 Scheme。
  appScheme,

  /// Universal Links 或 Android App Links。
  appLink,

  /// 白名单内的外部网页。
  externalWeb,
}

/// 深链失效原因。
enum DeepLinkInvalidReason {
  /// 输入为空或无法解析。
  invalidUri,

  /// Scheme 未配置或不受支持。
  unsupportedScheme,

  /// host 不在安全白名单内。
  blockedHost,

  /// 链接包含不允许的 URL 结构。
  unsafeUri,

  /// 路径没有声明为深链目标。
  unknownPath,

  /// query 参数未通过路由白名单校验。
  invalidQuery,
}

/// 经过校验后可交给 App 层执行的链接命令。
/// 深链解析结果。
sealed class DeepLinkResolution {
  const DeepLinkResolution();
}

/// 解析成功的链接结果。
final class DeepLinkAccepted extends DeepLinkResolution {
  const DeepLinkAccepted(this.command);

  /// 可执行的链接命令。
  final AppNavigationCommand command;
}

/// 解析失败的链接结果。
final class DeepLinkInvalid extends DeepLinkResolution {
  const DeepLinkInvalid(this.reason);

  /// 分类后的失效原因，不包含未校验的导航目标。
  final DeepLinkInvalidReason reason;
}
