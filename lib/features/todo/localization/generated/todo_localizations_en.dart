// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'todo_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class TodoLocalizationsEn extends TodoLocalizations {
  TodoLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get empty => 'No todos yet. Add one to get started.';

  @override
  String get createTitle => 'Create Todo';
}
