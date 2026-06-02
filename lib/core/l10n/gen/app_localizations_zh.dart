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

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get search => '搜索';

  @override
  String get add => '添加';

  @override
  String get delete => '删除';

  @override
  String get selectAll => '全选';

  @override
  String get save => '保存';

  @override
  String get done => '完成';

  @override
  String get noData => '暂无数据';

  @override
  String get settings => '设置';

  @override
  String get logout => '退出登录';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String welcomeUser(String username) {
    return '欢迎，$username';
  }

  @override
  String get loginFailed => '登录失败';

  @override
  String get networkErrorHint => '网络异常，请检查连接';

  @override
  String get serverErrorHint => '服务异常，请稍后重试';

  @override
  String get unknownHint => '请求失败，请稍后重试';

  @override
  String get timeoutHint => '请求超时，请稍后重试';

  @override
  String get reqErrorHint => '请求构造失败，请稍后重试';

  @override
  String get dataParseHint => '数据解析失败，请稍后重试';
}
