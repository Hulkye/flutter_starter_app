import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/router.dart';
import 'pages/login_page.dart';

/// Auth 路由对象。
final class LoginRoute extends AppPageRoute {
  const LoginRoute();

  @override
  String get path => '/login';

  @override
  bool get public => true;

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return LoginPage();
  }
}
