import 'package:flutter/widgets.dart';

import 'package:flutter_starter_app/core/router/router.dart';
import 'pages/todo_page.dart';

final class TodoRoute extends AppPageRoute {
  const TodoRoute();

  @override
  String get path => '/todo';

  @override
  bool get public => true;

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const TodoPage();
  }
}
