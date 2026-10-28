import 'package:flutter_starter_app/shared/design_system/design_system.dart';

final class TodoAsset extends AssetData {
  const TodoAsset({required this.emptyState});

  final String emptyState;

  static const light = TodoAsset(
    emptyState: 'assets/features/todo/todo_empty.png',
  );

  static const dark = TodoAsset(
    emptyState: 'assets/features/todo/dark/todo_empty.png',
  );
}
