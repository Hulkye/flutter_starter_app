import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/export.dart';
import '../domain/web_page_config.dart';
import 'web_page.dart';

final class WebPageRoute extends AppPageRoute<WebPageConfig> {
  const WebPageRoute();

  static const String pathValue = '/web';

  @override
  String get path => pathValue;

  @override
  WebPageConfig parse(AppRouteState state) => WebPageConfig.fromRouteState(
    queryParameters: state.queryParameters,
    extra: state.extra,
  );

  @override
  Widget buildPage(BuildContext context, WebPageConfig config) {
    return WebPage(config: config);
  }
}

final class AuthWebPageRoute extends AppPageRoute<WebPageConfig> {
  const AuthWebPageRoute();

  static const String pathValue = '/auth-web';

  @override
  String get path => pathValue;

  @override
  WebPageConfig parse(AppRouteState state) => WebPageConfig.fromRouteState(
    queryParameters: state.queryParameters,
    extra: state.extra,
  );

  @override
  Widget buildPage(BuildContext context, WebPageConfig config) {
    return WebPage(config: config);
  }
}

final class WebPageTarget extends AppRouteTargetBase {
  const WebPageTarget(this.config);

  final WebPageConfig config;

  @override
  String get location => _buildLocation(
    WebPageRoute.pathValue,
    url: config.url,
    title: config.title,
  );

  @override
  Object? get extra => config;
}

final class AuthWebPageTarget extends AppRouteTargetBase {
  const AuthWebPageTarget(this.config);

  final WebPageConfig config;

  @override
  String get location => _buildLocation(
    AuthWebPageRoute.pathValue,
    url: config.url,
    title: config.title,
  );

  @override
  Object? get extra => config;
}

String _buildLocation(String path, {String? url, String? title}) {
  final queryParameters = <String, String>{};
  final trimmedUrl = url?.trim();
  if (trimmedUrl != null && trimmedUrl.isNotEmpty) {
    queryParameters['url'] = trimmedUrl;
  }
  final trimmedTitle = title?.trim();
  if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
    queryParameters['title'] = trimmedTitle;
  }
  return AppRouteLocation.withQuery(path, queryParameters);
}
