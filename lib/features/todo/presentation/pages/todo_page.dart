import 'package:flutter/material.dart';
import 'package:flutter_starter_app/shared/widgets/input/base_text_field.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/util/screen_util.dart';
import '../../../../shared/presentation/presentation.dart';
import '../../../../shared/widgets/button/primary_round_button.dart';
import '../../../../shared/widgets/sheet/common_confirm_sheet.dart';
import '../../domain/entities/todo_item.dart';
import '../viewmodels/todo_viewmodel.dart';

final class TodoPage extends BasePage {
  const TodoPage({super.key});

  @override
  PageLogic createPageLogic() => _TodoPageLogic();

  @override
  PreferredSizeWidget? appBar(PageScope scope) {
    return AppBar(title: Text(scope.context.i18n.todoTitle));
  }

  @override
  Widget page(PageScope scope) {
    final state = scope.ref.watch(todoViewModelProvider);
    final vm = scope.ref.read(todoViewModelProvider.notifier);

    if (!state.initialized) {
      return ColoredBox(color: scope.context.appColor.backgroundPrimary);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TodoInputCard(state: state, vm: vm),
          SizedBox(height: 18.w),
          _TodoStats(state: state),
          SizedBox(height: 18.w),
          if (state.todos.isEmpty)
            _TodoEmptyState()
          else
            ...state.todos.map(
              (todo) => Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: _TodoListItem(todo: todo, vm: vm),
              ),
            ),
        ],
      ),
    );
  }
}

final class _TodoPageLogic extends PageLogic {
  @override
  void onReady() {
    ref.read(todoViewModelProvider.notifier).loadTodos();
  }
}

final class _TodoInputCard extends StatefulWidget {
  const _TodoInputCard({required this.state, required this.vm});

  final TodoState state;
  final TodoViewModel vm;

  @override
  State<_TodoInputCard> createState() => _TodoInputCardState();
}

final class _TodoInputCardState extends State<_TodoInputCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.draftTitle);
  }

  @override
  void didUpdateWidget(covariant _TodoInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.draftTitle.isNotEmpty &&
        widget.state.draftTitle.isEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColor.compBackgroundPrimary,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.appColor.compDivider),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.i18n.todoCreateTitle,
              style: TextStyle(
                color: context.appColor.fontPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.w),
            BaseTextField(
              controller: _controller,
              hintText: context.i18n.todoInputHint,
              onChanged: vm.updateDraft,
            ),
            SizedBox(height: 16.w),
            PrimaryRoundButton(
              context: context,
              label: context.i18n.add,
              onPressed: vm.addTodo,
              height: 44.w,
            ),
          ],
        ),
      ),
    );
  }
}

final class _TodoStats extends StatelessWidget {
  const _TodoStats({required this.state});

  final TodoState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TodoStatItem(
            label: context.i18n.todoTotalCount,
            value: '${state.todos.length}',
            color: context.appColor.brand,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _TodoStatItem(
            label: context.i18n.todoCompletedCount,
            value: '${state.completedCount}',
            color: context.appColor.confirm,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _TodoStatItem(
            label: context.i18n.todoRemainingCount,
            value: '${state.remainingCount}',
            color: context.appColor.alert,
          ),
        ),
      ],
    );
  }
}

final class _TodoStatItem extends StatelessWidget {
  const _TodoStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.w),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.w),
            Text(
              label,
              style: TextStyle(
                color: context.appColor.fontSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _TodoListItem extends StatelessWidget {
  const _TodoListItem({required this.todo, required this.vm});

  final TodoItem todo;
  final TodoViewModel vm;

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColor;
    final textColor = todo.isCompleted
        ? appColor.fontTertiary
        : appColor.fontPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: appColor.compBackgroundPrimary,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: appColor.compDivider),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.w),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.w),
          leading: IconButton(
            onPressed: () => vm.toggleTodo(todo.id),
            icon: Icon(
              todo.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color:
                  todo.isCompleted ? appColor.confirm : appColor.iconTertiary,
            ),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: textColor,
              fontSize: 16.sp,
              decoration:
                  todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            onPressed: () => _confirmDelete(context),
            icon: Icon(Icons.delete_outline, color: appColor.alert),
          ),
          onTap: () => vm.toggleTodo(todo.id),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showCommonConfirmSheet(
      context,
      title: context.i18n.todoDeleteConfirmTitle,
      content: context.i18n.todoDeleteConfirmContent,
      confirmLabel: context.i18n.delete,
      onConfirm: () => vm.deleteTodo(todo.id),
    );
  }
}

final class _TodoEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.w),
      child: Column(
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 54.w,
            color: context.appColor.iconTertiary,
          ),
          SizedBox(height: 12.w),
          Text(
            context.i18n.todoEmpty,
            style: TextStyle(
              color: context.appColor.fontSecondary,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
