import 'package:flutter/widgets.dart';

import '../../core/router/definitions/router_definitions.dart';
import 'splash_page.dart';

final class SplashRoute extends AppPageRoute {
  const SplashRoute();

  @override
  String get path => '/splash';

  @override
  bool get public => true;

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const SplashPage();
  }
}
