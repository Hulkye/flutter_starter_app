import '../core/feature/app_feature.dart';
import '../core/router/app_route_define.dart';
import 'auth/auth_feature.dart';
import 'home/home_feature.dart';
import 'profile/profile_feature.dart';
import 'todo/todo_feature.dart';

export 'auth/auth_feature.dart';
export 'home/home_feature.dart';
export 'profile/profile_feature.dart';
export 'todo/todo_feature.dart';

/// App 中启用的所有业务 Feature。
const List<AppFeature> appFeatures = [
  HomeFeature(),
  AuthFeature(),
  ProfileFeature(),
  TodoFeature(),
];

/// 从所有 Feature 中汇聚出的路由表。
final List<AppRouteDefine> appFeatureRoutes = [
  for (final feature in appFeatures) ...feature.routes,
];
