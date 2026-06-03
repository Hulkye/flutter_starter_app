import 'package:flutter/widgets.dart';

import '../../../core/router/app_route_define.dart';
import 'pages/todo_page.dart';

final class TodoRoute extends AppRouteDefine {
  const TodoRoute();

  @override
  String get path => '/todo';

  @override
  bool get public => true;

  @override
  Widget buildPage(BuildContext context, RouteState state) {
    return const TodoPage();
  }
}
