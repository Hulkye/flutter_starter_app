/// 应用导航接口。
///
/// Presentation/Page 层依赖该接口，而不是直接依赖 GoRouter。
/// Widget、测试都可以使用同一套导航协议。
abstract interface class BaseNavigator {
  /// 跳转到目标 location 并替换当前 location（适合 tab 切换/回首页/深链）。
  void go(String location);

  /// 压栈打开目标 location，可返回结果。
  Future<T?> push<T extends Object?>(String location);

  /// 替换当前页。
  void replace(String location);

  /// 清空当前栈并跳转。
  void replaceAll(String location);

  /// 返回上一页。
  void back<T extends Object?>([T? result]);

  /// 是否可以返回。
  bool canBack();
}
