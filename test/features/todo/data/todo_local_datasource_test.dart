import 'package:flutter_starter_app/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoLocalDataSource', () {
    test('returns seeded todos as an immutable list', () async {
      final dataSource = TodoLocalDataSource();

      final todos = await dataSource.fetchTodos();

      expect(todos, hasLength(3));
      expect(todos.where((todo) => todo.isCompleted), hasLength(1));
      expect(() => todos.add(todos.first), throwsUnsupportedError);
    });

    test('adds new todo to the top of the list', () async {
      final dataSource = TodoLocalDataSource();

      final todos = await dataSource.addTodo('Write tests');

      expect(todos, hasLength(4));
      expect(todos.first.title, 'Write tests');
      expect(todos.first.isCompleted, isFalse);
    });

    test('toggles and deletes todo items', () async {
      final dataSource = TodoLocalDataSource();
      final first = (await dataSource.fetchTodos()).first;

      final toggled = await dataSource.toggleTodo(first.id);
      expect(toggled.first.isCompleted, isTrue);

      final remaining = await dataSource.deleteTodo(first.id);
      expect(remaining.any((todo) => todo.id == first.id), isFalse);
      expect(remaining, hasLength(2));
    });
  });
}
