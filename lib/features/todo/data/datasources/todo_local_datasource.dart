import '../../domain/entities/todo_item.dart';

final class TodoLocalDataSource {
  final List<TodoItem> _todos = [
    const TodoItem(id: '1', title: 'Review the MVVM base classes'),
    const TodoItem(
      id: '2',
      title: 'Add a new Feature with Clean Architecture',
      isCompleted: true,
    ),
    const TodoItem(id: '3', title: 'Register the route and navigate from Home'),
  ];
  int _nextId = 4;

  Future<List<TodoItem>> fetchTodos() async {
    return List.unmodifiable(_todos);
  }

  Future<List<TodoItem>> addTodo(String title) async {
    _todos.insert(0, TodoItem(id: '${_nextId++}', title: title));
    return fetchTodos();
  }

  Future<List<TodoItem>> toggleTodo(String id) async {
    final index = _todos.indexWhere((item) => item.id == id);
    if (index < 0) return fetchTodos();

    final item = _todos[index];
    _todos[index] = item.copyWith(isCompleted: !item.isCompleted);
    return fetchTodos();
  }

  Future<List<TodoItem>> deleteTodo(String id) async {
    _todos.removeWhere((item) => item.id == id);
    return fetchTodos();
  }
}
