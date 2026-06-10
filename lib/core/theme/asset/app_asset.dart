import '../data/res_data.dart';

// const String _suffix = '.webp';

class AppAsset extends AssetData {
  final String logo;
  final String emptyState;
  final String iconFillSuccess;
  final String iconFillError;
  final String tabTodo;
  final String tabTodoSelected;
  final String tabProfile;
  final String tabProfileSelected;

  AppAsset({
    this.logo = 'assets/images/logo.png',
    this.emptyState = 'assets/images/logo.png',
    this.iconFillSuccess = 'assets/images/logo.png',
    this.iconFillError = 'assets/images/logo.png',
    this.tabTodo = 'assets/images/tab_todo.svg',
    this.tabTodoSelected = 'assets/images/tab_todo_selected.svg',
    this.tabProfile = 'assets/images/tab_profile.svg',
    this.tabProfileSelected = 'assets/images/tab_profile_selected.svg',
  });
}
