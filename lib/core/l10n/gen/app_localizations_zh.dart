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
  String get goToTodo => '前往 Todo 示例';

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
  String get todoTitle => 'Todo 示例';

  @override
  String get todoCreateTitle => '创建 Todo';

  @override
  String get todoInputHint => '输入待办事项';

  @override
  String get todoEmptyTitleHint => '请输入待办事项';

  @override
  String get todoTotalCount => '总数';

  @override
  String get todoCompletedCount => '已完成';

  @override
  String get todoRemainingCount => '待完成';

  @override
  String get todoDeleteConfirmTitle => '删除待办';

  @override
  String get todoDeleteConfirmContent => '确认删除这条待办事项吗？';

  @override
  String get todoEmpty => '暂无待办，添加一条试试吧';

  @override
  String get loginFailed => '登录失败';

  @override
  String get accountHint => '请输入账号';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get lightMode => '浅色';

  @override
  String get darkMode => '深色';

  @override
  String get systemMode => '跟随系统';

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
