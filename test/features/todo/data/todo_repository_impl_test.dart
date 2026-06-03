import 'package:flutter_starter_app/features/todo/data/datasources/todo_local_datasource.dart';
import 'package:flutter_starter_app/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodoRepositoryImpl', () {
    test('trims todo title before adding', () async {
      final repository = TodoRepositoryImpl(TodoLocalDataSource());

      final todos = await repository.addTodo('  Write quality gates  ');

      expect(todos.first.title, 'Write quality gates');
    });

    test('rejects empty todo title', () async {
      final repository = TodoRepositoryImpl(TodoLocalDataSource());

      expect(() => repository.addTodo('   '), throwsArgumentError);
    });
  });
}
