import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  return TodoLocalDataSource();
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(ref.watch(todoLocalDataSourceProvider));
});

final class TodoRepositoryImpl implements TodoRepository {
  const TodoRepositoryImpl(this._dataSource);

  final TodoLocalDataSource _dataSource;

  @override
  Future<List<TodoItem>> fetchTodos() {
    return _dataSource.fetchTodos();
  }

  @override
  Future<List<TodoItem>> addTodo(String title) {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Todo title cannot be empty');
    }
    return _dataSource.addTodo(trimmedTitle);
  }

  @override
  Future<List<TodoItem>> toggleTodo(String id) {
    return _dataSource.toggleTodo(id);
  }

  @override
  Future<List<TodoItem>> deleteTodo(String id) {
    return _dataSource.deleteTodo(id);
  }
}
