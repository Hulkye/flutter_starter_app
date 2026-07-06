import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/todo/data/datasources/todo_local_datasource.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';

/// App 组合层的 Feature 默认依赖装配。
///
/// Repository 抽象 Provider 位于 domain 层，默认 data 实现在这里注入，
/// 避免 presentation/ViewModel 直接依赖 data。
List<Override> createAppFeatureProviderOverrides() {
  return <Override>[
    ...createAuthFeatureProviderOverrides(),
    ...createTodoFeatureProviderOverrides(),
  ];
}

List<Override> createAuthFeatureProviderOverrides() {
  return <Override>[
    authRepositoryBindingProvider.overrideWith(
      (ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
    ),
  ];
}

List<Override> createTodoFeatureProviderOverrides() {
  return <Override>[
    todoRepositoryBindingProvider.overrideWith(
      (ref) => TodoRepositoryImpl(ref.watch(todoLocalDataSourceProvider)),
    ),
  ];
}
