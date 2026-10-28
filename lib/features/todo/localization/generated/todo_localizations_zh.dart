// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'todo_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class TodoLocalizationsZh extends TodoLocalizations {
  TodoLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get empty => '暂无待办，添加一条试试吧';

  @override
  String get createTitle => '创建 Todo';
}
