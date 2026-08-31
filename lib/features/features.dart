import '../core/config/env_config.dart';
import '../core/feature/app_feature.dart';
import '../core/feature/app_feature_registry.dart';
import 'auth/auth_feature.dart';
import 'profile/profile_feature.dart';
import 'todo/todo_feature.dart';

/// App 中启用的所有业务 Feature。
const List<AppFeature> appFeatures = [
  AuthFeature(),
  TodoFeature(),
  ProfileFeature(),
];

/// 构建指定环境下唯一的 Feature 注册结果。
AppFeatureRegistry createAppFeatureRegistry(EnvTag environment) {
  return AppFeatureRegistry(candidates: appFeatures, environment: environment);
}
