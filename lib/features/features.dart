import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import '../core/feature/app_feature.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'auth/auth_feature.dart';
import 'profile/profile_feature.dart';
import 'todo/todo_feature.dart';

export 'auth/auth_feature.dart';
export 'profile/profile_feature.dart';
export 'todo/todo_feature.dart';

/// App 中启用的所有业务 Feature。
const List<AppFeature> appFeatures = [
  AuthFeature(),
  TodoFeature(),
  ProfileFeature(),
];

final List<AppTabEntry> appFeatureTabs = [
  for (final feature in appFeatures) ...feature.tabs,
];

final Set<String> _appFeatureTabRoutePaths = {
  for (final tab in appFeatureTabs) tab.route.path,
};

final List<AppPageRoute> appFeatureRoutes = [
  for (final feature in appFeatures)
    for (final route in feature.routes)
      if (!_appFeatureTabRoutePaths.contains(route.path)) route,
];
