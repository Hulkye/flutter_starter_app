import 'package:app_deep_link/app_deep_link.dart';

import '../../core/navigation/app_navigation_command.dart';
import '../../shared/webview/domain/web_page_config.dart';
import '../../shared/webview/presentation/webview_routes.dart';

/// Deep Link capability 专用的宿主导航命令解析器。
///
/// [DeepLinkMatch] 是外部 Deep Link package 的匹配结果，因此该解析器属于
/// Deep Link integration，不是 App 通用导航抽象。package 负责 URI 安全校验
/// 和路径匹配，本类负责宿主参数语义和 App 专属页面配置。
final class DeepLinkNavigationCommandResolver {
  const DeepLinkNavigationCommandResolver();

  AppNavigationCommand? resolve(DeepLinkMatch match) {
    if (match.route.key == WebPageRoute.pathValue) {
      return _resolveWebPage(match);
    }

    return AppNavigationCommand(
      source: AppNavigationSource.deepLink,
      path: match.route.path,
      requiresAuthentication: match.route.requiresAuthentication,
      queryParameters: match.queryParameters,
    );
  }

  AppNavigationCommand? _resolveWebPage(DeepLinkMatch match) {
    final rawUrl = match.queryParameters['url'];
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final normalizedUrl = _normalizeWebUrl(rawUrl);
    if (normalizedUrl == null) return null;

    return AppNavigationCommand(
      source: AppNavigationSource.deepLink,
      path: const WebPageRoute().path,
      requiresAuthentication: false,
      queryParameters: <String, String>{'url': normalizedUrl},
      extra: WebPageConfig(url: normalizedUrl),
    );
  }

  String? _normalizeWebUrl(String value) {
    final trimmed = value.trim();
    final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
    return WebPageConfig.normalizeWebUri(candidate)?.toString();
  }
}
