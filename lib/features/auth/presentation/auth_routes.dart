import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/export.dart';
import 'pages/login_page.dart';

/// Auth 路由对象。
final class LoginRoute extends AppPageRoute<LoginRouteArgs> {
  const LoginRoute();

  static const String routeKey = 'auth.login';
  static const String pathValue = '/login';

  @override
  String get path => pathValue;

  @override
  AppRouteMetadata get metadata =>
      const AppRouteMetadata(key: routeKey, path: pathValue);

  @override
  LoginRouteArgs parse(AppRouteState state) => LoginRouteArgs(
    redirectLocation: readInternalRedirect(state.queryParameters['redirect']),
  );

  @override
  Widget buildPage(BuildContext context, LoginRouteArgs args) {
    return LoginPage(redirectLocation: args.redirectLocation);
  }
}

final class LoginRouteArgs {
  const LoginRouteArgs({required this.redirectLocation});

  final String? redirectLocation;
}

final class LoginTarget extends AppRouteTargetBase {
  const LoginTarget();

  @override
  String get location => LoginRoute.pathValue;
}
