// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get homeTitle => '首页';

  @override
  String get profileTitle => '我的';

  @override
  String get goToProfile => '前往我的页面';

  @override
  String get requestDemo => '请求示例接口';

  @override
  String get requesting => '请求中...';

  @override
  String get switchThemeMode => '切换主题模式';

  @override
  String get currentThemeMode => '当前主题模式';

  @override
  String get currentLogoAsset => '当前Logo资源';
}
