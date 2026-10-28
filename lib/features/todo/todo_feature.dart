import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import 'package:flutter_starter_app/core/router/export.dart';
import 'package:flutter_starter_app/shared/design_system/design_system.dart';
import 'package:flutter_starter_app/core/feature/app_route_policy.dart';

import '../../core/feature/app_feature.dart';
import '../../core/feature/app_external_route.dart';
import '../../core/feature/app_feature_metadata.dart';
import 'localization/todo_localization.dart';
import 'data/datasources/todo_local_datasource.dart';
import 'data/repositories/todo_repository_impl.dart';
import 'domain/repositories/todo_repository.dart';
import 'presentation/todo_routes.dart';
import 'design/todo_design.dart';

final class TodoFeature extends AppFeature {
  const TodoFeature();

  @override
  AppFeatureMetadata get metadata =>
      const AppFeatureMetadata(key: 'todo', priority: 200);

  @override
  List<AppPageRoute<dynamic>> get routes => const [TodoRoute()];

  @override
  List<AppRoutePolicy> get routePolicies => const [
    AppRoutePolicy(routeKey: TodoRoute.routeKey, requiresAuthentication: false),
  ];

  @override
  List<AppTabEntry> get tabs => const [_TodoTabEntry()];

  @override
  List<AppExternalRoute> get externalRoutes => const [
    AppExternalRoute(key: 'todo', route: TodoRoute()),
  ];

  @override
  List<Override> get providerOverrides {
    return <Override>[
      todoRepositoryBindingProvider.overrideWith(
        (ref) => TodoRepositoryImpl(ref.watch(todoLocalDataSourceProvider)),
      ),
    ];
  }

  @override
  List<Object> get lightThemeExtensions => const [
    TodoColorExtension.light,
    TodoAssetExtension.light,
  ];

  @override
  List<Object> get darkThemeExtensions => const [
    TodoColorExtension.dark,
    TodoAssetExtension.dark,
  ];

  @override
  List<LocalizationsDelegate<dynamic>> get localizationDelegates => const [
    TodoLocalizations.delegate,
  ];
}

final class _TodoTabEntry extends AppTabEntry {
  const _TodoTabEntry();

  @override
  String get key => 'todo.root';

  @override
  String label(BuildContext context) => context.todoL10n.createTitle;

  @override
  String icon(BuildContext context) => context.appAsset.tabTodo;

  @override
  String selectedIcon(BuildContext context) => context.appAsset.tabTodoSelected;

  @override
  AppPageRoute<dynamic> get route => const TodoRoute();

  @override
  AppRouteTarget get initialTarget => const TodoTarget();
}
