import 'package:flutter/widgets.dart';

import '../../../../core/router/app_route_define.dart';
import 'pages/profile_page.dart';

/// Profile 路由。
final class ProfileRoute extends AppRouteDefine {
  const ProfileRoute();

  @override
  String get path => '/profile';

  @override
  Widget buildPage(BuildContext context, RouteState state) {
    return const ProfilePage();
  }
}
