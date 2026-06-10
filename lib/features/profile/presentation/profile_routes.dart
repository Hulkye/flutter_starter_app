import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/router.dart';
import 'pages/profile_page.dart';

/// Profile 路由。
final class ProfileRoute extends AppPageRoute {
  const ProfileRoute();

  @override
  String get path => '/profile';

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const ProfilePage();
  }
}
