import 'package:flutter_starter_app/core/router/router.dart';

import '../../core/feature/app_feature.dart';
import 'presentation/todo_routes.dart';

export 'presentation/todo_routes.dart';

final class TodoFeature extends AppFeature {
  const TodoFeature();

  @override
  String get name => 'todo';

  @override
  List<AppPageRoute> get routes => const [TodoRoute()];
}
