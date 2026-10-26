import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/export.dart';
import 'pages/todo_page.dart';

final class TodoRoute extends AppPageRoute<void> {
  const TodoRoute();

  static const String routeKey = 'todo.home';
  static const String pathValue = '/todo';

  @override
  String get path => pathValue;

  @override
  AppRouteMetadata get metadata =>
      const AppRouteMetadata(key: routeKey, path: pathValue);

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const TodoPage();
  }
}

final class TodoTarget extends AppRouteTargetBase {
  const TodoTarget();

  @override
  String get location => TodoRoute.pathValue;
}
