import 'package:flutter/widgets.dart';

import '../../../core/router/definitions/router_definitions.dart';
import 'splash_page.dart';

final class SplashRoute extends AppPageRoute<void> {
  const SplashRoute();

  @override
  String get path => '/splash';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const SplashPage();
  }
}

final class SplashTarget extends AppRouteTargetBase {
  const SplashTarget();

  @override
  String get location => const SplashRoute().path;
}
