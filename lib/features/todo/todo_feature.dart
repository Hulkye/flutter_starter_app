import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import 'package:flutter_starter_app/core/l10n/l10n.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/core/theme/theme.dart';

import '../../core/feature/app_feature.dart';
import 'data/datasources/todo_local_datasource.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'domain/repositories/todo_repository.dart';
import 'presentation/todo_routes.dart';

final class TodoFeature extends AppFeature {
  const TodoFeature();

  @override
  String get name => 'todo';

  @override
  List<AppPageRoute> get routes => const [TodoRoute()];

  @override
  List<AppTabEntry> get tabs => const [_TodoTabEntry()];

  @override
  List<Override> get providerOverrides {
    return <Override>[
      todoRepositoryBindingProvider.overrideWith(
        (ref) => TodoRepositoryImpl(ref.watch(todoLocalDataSourceProvider)),
      ),
    ];
  }
}

final class _TodoTabEntry extends AppTabEntry {
  const _TodoTabEntry();

  @override
  String get key => 'todo.root';

  @override
  String label(BuildContext context) => context.i18n.todoTitle;

  @override
  String icon(BuildContext context) => context.appAsset.tabTodo;

  @override
  String selectedIcon(BuildContext context) => context.appAsset.tabTodoSelected;

  @override
  AppPageRoute get route => const TodoRoute();
}
