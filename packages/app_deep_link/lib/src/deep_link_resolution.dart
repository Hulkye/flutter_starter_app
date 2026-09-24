import 'deep_link_route.dart';

/// URI 进入 App 的来源类型。
enum DeepLinkSourceKind { appScheme, appLink }

/// package 拒绝 URI 的分类原因。
enum DeepLinkInvalidReason {
  invalidUri,
  unsupportedScheme,
  blockedHost,
  unsafeUri,
  unknownPath,
  invalidQuery,
}

/// Deep Link 解析结果，不包含任何宿主导航实现细节。
sealed class DeepLinkResolution {
  const DeepLinkResolution();
}

/// URI 命中宿主注册路由。
final class DeepLinkAccepted extends DeepLinkResolution {
  const DeepLinkAccepted(this.match);

  /// 已完成来源、host、URI 结构和路由匹配校验的结果。
  final DeepLinkMatch match;
}

/// URI 未通过 package 校验。
final class DeepLinkInvalid extends DeepLinkResolution {
  const DeepLinkInvalid(this.reason);

  /// 可用于日志或产品层提示的分类原因。
  final DeepLinkInvalidReason reason;
}

/// Deep Link 命中后的通用路由数据。
final class DeepLinkMatch {
  const DeepLinkMatch({
    required this.route,
    required this.source,
    this.queryParameters = const <String, String>{},
  });

  /// 被命中的宿主路由描述。
  final DeepLinkRoute route;

  /// URI 使用的来源类型。
  final DeepLinkSourceKind source;

  /// 已解码的 query 参数；参数语义由宿主路由解释。
  final Map<String, String> queryParameters;
}
