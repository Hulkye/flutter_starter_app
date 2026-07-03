import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/router.dart';
import '../domain/entities/web_page_config.dart';
import 'pages/web_page.dart';

final class WebPageRoute extends AppPageRoute {
  const WebPageRoute({this.url, this.title});

  final String? url;
  final String? title;

  static const String pathValue = '/web';

  @override
  String get path => pathValue;

  @override
  bool get public => true;

  @override
  String get location => _buildLocation(pathValue, url: url, title: title);

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return WebPage(
      config: WebPageConfig.fromRouteState(
        queryParameters: state.queryParameters,
        extra: state.extra,
      ),
    );
  }
}

final class AuthWebPageRoute extends AppPageRoute {
  const AuthWebPageRoute({this.url, this.title});

  final String? url;
  final String? title;

  static const String pathValue = '/auth-web';

  @override
  String get path => pathValue;

  @override
  String get location => _buildLocation(pathValue, url: url, title: title);

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return WebPage(
      config: WebPageConfig.fromRouteState(
        queryParameters: state.queryParameters,
        extra: state.extra,
      ),
    );
  }
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
  if (queryParameters.isEmpty) {
    return path;
  }
  return Uri(path: path, queryParameters: queryParameters).toString();
}
