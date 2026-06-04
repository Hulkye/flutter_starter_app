import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../shared/presentation/presentation.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_item.dart';

final class TodoState extends BaseState {
  const TodoState({
    this.initialized = false,
    this.todos = const [],
    this.draftTitle = '',
  });

  final bool initialized;
  final List<TodoItem> todos;
  final String draftTitle;

  int get completedCount => todos.where((todo) => todo.isCompleted).length;

  int get remainingCount => todos.length - completedCount;

  TodoState copyWith({
    bool? initialized,
    List<TodoItem>? todos,
    String? draftTitle,
  }) {
    return TodoState(
      initialized: initialized ?? this.initialized,
      todos: todos ?? this.todos,
      draftTitle: draftTitle ?? this.draftTitle,
    );
  }
}

final class TodoViewModel extends BaseVM<TodoState> {
  @override
  TodoState initialState() => const TodoState();

  Future<void> loadTodos() async {
    final todos = await ref.read(todoRepositoryProvider).fetchTodos();
    state = state.copyWith(todos: todos, initialized: true);
  }

  void updateDraft(String value) {
    state = state.copyWith(draftTitle: value);
  }

  Future<void> addTodo() async {
    final title = state.draftTitle.trim();
    if (title.isEmpty) {
      PresentationHelper.emitHint(
        ref.read(appLocalizationsProvider).todoEmptyTitleHint,
      );
      return;
    }

    await PresentationHelper.runWithLoading(() async {
      final todos = await ref.read(todoRepositoryProvider).addTodo(title);
      state = state.copyWith(todos: todos, draftTitle: '');
    });
  }

  Future<void> toggleTodo(String id) async {
    final todos = await ref.read(todoRepositoryProvider).toggleTodo(id);
    state = state.copyWith(todos: todos);
  }

  Future<void> deleteTodo(String id) async {
    await PresentationHelper.runWithLoading(() async {
      final todos = await ref.read(todoRepositoryProvider).deleteTodo(id);
      state = state.copyWith(todos: todos);
    });
  }
}

final todoViewModelProvider = NotifierProvider<TodoViewModel, TodoState>(
  TodoViewModel.new,
);
