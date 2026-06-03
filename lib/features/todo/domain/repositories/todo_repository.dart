import '../entities/todo_item.dart';

abstract interface class TodoRepository {
  Future<List<TodoItem>> fetchTodos();

  Future<List<TodoItem>> addTodo(String title);

  Future<List<TodoItem>> toggleTodo(String id);

  Future<List<TodoItem>> deleteTodo(String id);
}
