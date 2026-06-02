/// 页面状态基类。
///
/// Feature 的 ViewModel State 应继承此类，只保留影响页面渲染结构的通用字段。
/// Loading / Hint 属于一次性 UI 反馈，由 [BaseVM] 直接处理，不进入 State。
abstract class BaseState {
  const BaseState({this.isReady = true});

  /// 页面初始数据是否就绪。
  ///
  /// `false` 时 [BasePage] 展示 [BasePage.prePage]，`true` 时展示 [BasePage.page]。
  final bool isReady;

  /// 仅更新基类字段，返回新的 [BaseState]。
  ///
  /// 子类应覆写此方法以保留自身字段。
  BaseState copyWithBase({bool? isReady});
}
