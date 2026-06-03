// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get homeTitle => 'Home';

  @override
  String get profileTitle => 'Profile';

  @override
  String get goToProfile => 'Go to profile';

  @override
  String get goToTodo => 'Go to Todo example';

  @override
  String get requestDemo => 'Request demo API';

  @override
  String get requesting => 'Requesting...';

  @override
  String get switchThemeMode => 'Switch theme mode';

  @override
  String get currentThemeMode => 'Current theme mode';

  @override
  String get currentLogoAsset => 'Current logo asset';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get search => 'Search';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get selectAll => 'Select all';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get noData => 'No data';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Log out';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String welcomeUser(String username) {
    return 'Welcome, $username';
  }

  @override
  String get todoTitle => 'Todo Example';

  @override
  String get todoCreateTitle => 'Create Todo';

  @override
  String get todoInputHint => 'Enter a todo item';

  @override
  String get todoEmptyTitleHint => 'Please enter a todo item';

  @override
  String get todoTotalCount => 'Total';

  @override
  String get todoCompletedCount => 'Completed';

  @override
  String get todoRemainingCount => 'Remaining';

  @override
  String get todoDeleteConfirmTitle => 'Delete todo';

  @override
  String get todoDeleteConfirmContent =>
      'Are you sure you want to delete this todo item?';

  @override
  String get todoEmpty => 'No todos yet. Add one to get started.';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get networkErrorHint => 'Network error. Please check your connection.';

  @override
  String get serverErrorHint => 'Server error. Please try again later.';

  @override
  String get unknownHint => 'Request failed. Please try again later.';

  @override
  String get timeoutHint => 'Request timed out. Please try again later.';

  @override
  String get reqErrorHint => 'Request setup failed. Please try again later.';

  @override
  String get dataParseHint => 'Failed to parse data. Please try again later.';
}
