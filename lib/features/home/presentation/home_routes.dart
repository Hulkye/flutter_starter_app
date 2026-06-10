import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/router.dart';
import 'pages/home_page.dart';

/// Home 路由。
final class HomeRoute extends AppPageRoute {
  const HomeRoute();

  @override
  String get path => '/home';

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const HomePage();
  }
}
