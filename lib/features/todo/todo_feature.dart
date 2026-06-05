import '../../core/feature/app_feature.dart';
import '../../core/router/app_route_define.dart';
import 'presentation/todo_routes.dart';

export 'presentation/todo_routes.dart';

final class TodoFeature extends AppFeature {
  const TodoFeature();

  @override
  String get name => 'todo';

  @override
  List<AppRouteDefine> get routes => const [TodoRoute()];
}
