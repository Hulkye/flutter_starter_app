import 'package:flutter/widgets.dart';

import '../../../../core/router/app_route_define.dart';
import 'pages/home_page.dart';

/// Home 路由。
final class HomeRoute extends AppRouteDefine {
  const HomeRoute();

  @override
  String get path => '/';

  @override
  Widget buildPage(BuildContext context, RouteState state) {
    return const HomePage();
  }
}
