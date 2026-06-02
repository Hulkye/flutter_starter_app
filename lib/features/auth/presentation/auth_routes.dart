import 'package:flutter/widgets.dart';

import '../../../core/router/app_route_define.dart';
import 'pages/login_page.dart';

/// Auth 路由对象。
final class LoginRoute extends AppRouteDefine {
  const LoginRoute();

  @override
  String get path => '/login';

  @override
  Widget buildPage(BuildContext context, RouteState state) {
    return LoginPage();
  }
}
