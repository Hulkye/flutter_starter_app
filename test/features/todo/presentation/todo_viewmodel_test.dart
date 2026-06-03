import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/features/todo/presentation/viewmodels/todo_viewmodel.dart';
import 'package:flutter_starter_app/shared/presentation/base_vm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/provider_container.dart';

void main() {
  group('TodoViewModel', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await prefsStorage.init();
      BaseVM.showHintHandler = null;
      BaseVM.showLoadingHandler = null;
      BaseVM.hideLoadingHandler = null;
    });

    tearDown(() {
      BaseVM.showHintHandler = null;
      BaseVM.showLoadingHandler = null;
      BaseVM.hideLoadingHandler = null;
    });

    test('loads seeded todos and marks state ready', () async {
      final container = createTestContainer();
      final vm = container.read(todoViewModelProvider.notifier);

      await vm.loadTodos();
      final state = container.read(todoViewModelProvider);

      expect(state.isReady, isTrue);
      expect(state.todos, hasLength(3));
      expect(state.completedCount, 1);
      expect(state.remainingCount, 2);
    });

    test('adds, toggles, and deletes todos', () async {
      final container = createTestContainer();
      final vm = container.read(todoViewModelProvider.notifier);
      await vm.loadTodos();

      vm.updateDraft('  Write ViewModel tests  ');
      await vm.addTodo();

      var state = container.read(todoViewModelProvider);
      expect(state.draftTitle, isEmpty);
      expect(state.todos, hasLength(4));
      expect(state.todos.first.title, 'Write ViewModel tests');

      await vm.toggleTodo(state.todos.first.id);
      state = container.read(todoViewModelProvider);
      expect(state.todos.first.isCompleted, isTrue);

      await vm.deleteTodo(state.todos.first.id);
      state = container.read(todoViewModelProvider);
      expect(state.todos, hasLength(3));
      expect(
        state.todos.any((todo) => todo.title == 'Write ViewModel tests'),
        isFalse,
      );
    });

    test('emits hint when adding empty todo', () async {
      final hints = <String>[];
      BaseVM.showHintHandler = hints.add;
      final container = createTestContainer();
      final vm = container.read(todoViewModelProvider.notifier);

      vm.updateDraft('   ');
      await vm.addTodo();

      expect(hints, contains('Please enter a todo item'));
      expect(container.read(todoViewModelProvider).todos, isEmpty);
    });
  });
}
