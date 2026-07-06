import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/todo_item.dart';

abstract interface class TodoRepository {
  Future<List<TodoItem>> fetchTodos();

  Future<List<TodoItem>> addTodo(String title);

  Future<List<TodoItem>> toggleTodo(String id);

  Future<List<TodoItem>> deleteTodo(String id);
}

/// TodoRepository 抽象 Provider。
///
/// presentation 只依赖该 Provider。默认 data 实现由 App 组合层通过
/// [todoRepositoryBindingProvider] 注入；测试或环境可以直接 override 本 Provider。
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return ref.watch(todoRepositoryBindingProvider);
});

/// TodoRepository 默认实现装配点。
///
/// 由 App 组合层注入 data 实现，避免 presentation 直接依赖 data。
final todoRepositoryBindingProvider = Provider<TodoRepository>((ref) {
  throw StateError(
    'todoRepositoryBindingProvider must be overridden by app composition.',
  );
});
