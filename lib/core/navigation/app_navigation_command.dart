import '../router/definitions/router_definitions.dart';

/// App 内统一导航命令的来源。
enum AppNavigationSource {
  /// App Scheme、Universal Links 或 Android App Links。
  deepLink,

  /// Push 消息点击。
  push,

  /// 通知点击。
  notification,

  /// OAuth 或其他外部回调。
  oauth,

  /// App 内部触发。
  internal,
}

/// 可由 Deep Link、Push 和其他入口共同使用的 App 导航命令。
///
/// 外部入口先转换为该宿主级命令，再由 PendingNavigationCoordinator 统一处理
/// bootstrap、认证和最终导航。
final class AppNavigationCommand {
  const AppNavigationCommand({
    required this.path,
    required this.source,
    required this.requiresAuthentication,
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
    this.extra,
  });

  /// App 内目标路径，例如 `/todo` 或 `/web`。
  final String path;

  /// 已解析的路径参数。
  final Map<String, String> pathParameters;

  /// 已解析的 query 参数；未知参数可由目标页面自行忽略。
  final Map<String, String> queryParameters;

  /// 命令来源。
  final AppNavigationSource source;

  /// 是否需要认证后执行。
  final bool requiresAuthentication;

  /// 页面需要的类型化附加数据，例如 WebPageConfig。
  final Object? extra;

  static const _targetResolver = AppRouteTargetResolver();

  /// 供 BaseNavigator 使用的完整内部 location。
  String get location => target.location;

  /// 将命令的导航载荷投影为类型化目标。
  ///
  /// 命令自身仍保留来源和认证要求等协调信息；Target 只承载最终导航
  /// 所需的 location 与 extra。
  AppRouteTarget get target => _targetResolver.resolve(
    path: path,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );
}
