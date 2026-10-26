import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/export.dart';
import 'pages/profile_page.dart';

/// Profile 路由。
final class ProfileRoute extends AppPageRoute<void> {
  const ProfileRoute();

  @override
  String get path => '/profile';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const ProfilePage();
  }
}

final class ProfileTarget extends AppRouteTargetBase {
  const ProfileTarget();

  @override
  String get location => const ProfileRoute().path;
}
