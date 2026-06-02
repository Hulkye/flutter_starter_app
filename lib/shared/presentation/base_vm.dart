import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/router_provider.dart';
import 'base_state.dart';

/// Loading 展示回调。
typedef ShowLoadingHandler = void Function({bool allowClick, bool crossPage});

/// Loading 隐藏回调。
typedef HideLoadingHandler = void Function();

/// Hint 展示回调。
typedef ShowHintHandler = void Function(String hint);

/// ViewModel 基类。
///
/// 泛型 [S] 为页面状态类型，须继承 [BaseState]。
///
/// ## 职责
///
/// 1. 管理页面状态（继承 [Notifier]）
/// 2. 提供标准生命周期钩子：init / onReady / onResume / onPause / onClose / dispose
/// 3. 处理页面默认交互：loading、hint、pop
/// 4. 提供 [runWithLoading] 包装异步任务
///
/// Loading / Hint 是一次性 UI 反馈，不进入 [BaseState]，避免页面状态被临时事件污染。
abstract class BaseVM<S extends BaseState> extends Notifier<S> {
  /// 全局 loading 展示实现。
  static ShowLoadingHandler? showLoadingHandler;

  /// 全局 loading 隐藏实现。
  static HideLoadingHandler? hideLoadingHandler;

  /// 全局 hint 展示实现。
  static ShowHintHandler? showHintHandler;

  bool _isShowingLoading = false;

  // ===========================================================================
  // Riverpod 初始化入口
  // ===========================================================================

  @override
  S build() {
    init();
    ref.onDispose(() {
      hideLoading();
      dispose();
    });
    return initialState();
  }

  /// 子类返回初始状态。
  S initialState();

  // ===========================================================================
  // 生命周期钩子
  // ===========================================================================

  /// VM 初始化时调用。
  ///
  /// 调用时机：Riverpod 创建 Notifier、执行 [build] 时。
  void init() {}

  /// 页面首帧后调用。
  ///
  /// 适合执行依赖页面已渲染后的操作，例如首次弹窗、埋点、首屏请求。
  void onReady() {}

  /// 页面恢复时调用。
  ///
  /// 当前实现覆盖：页面首帧后、App 从后台恢复。
  void onResume() {}

  /// 页面暂停时调用。
  ///
  /// 当前实现覆盖：页面 dispose 前、App 进入 inactive/paused/hidden。
  void onPause() {}

  /// 页面关闭时调用。
  ///
  /// 调用时机：页面 Widget dispose。与 [dispose] 的区别：
  /// - [onClose] 在页面 Widget 销毁时由 BasePage 调用（页面级）
  /// - [dispose] 在 Riverpod provider 销毁时由 ref.onDispose 调用（VM 级）
  /// 通常 [onClose] 先于 [dispose] 触发。
  void onClose() {}

  /// VM 销毁时调用。
  ///
  /// 调用时机：Riverpod provider dispose。
  void dispose() {}

  // ===========================================================================
  // 状态操作
  // ===========================================================================

  /// 标记页面为就绪。
  void markReady() {
    state = state.copyWithBase(isReady: true) as S;
  }

  /// 标记页面为未就绪。
  void markNotReady() {
    state = state.copyWithBase(isReady: false) as S;
  }

  // ===========================================================================
  // Loading
  // ===========================================================================

  /// 显示 loading。
  void showLoading({bool allowClick = false, bool crossPage = true}) {
    _isShowingLoading = true;
    showLoadingHandler?.call(allowClick: allowClick, crossPage: crossPage);
  }

  /// 隐藏 loading。
  void hideLoading() {
    if (!_isShowingLoading) return;
    _isShowingLoading = false;
    hideLoadingHandler?.call();
  }

  /// 执行异步操作，自动管理 loading 和 hint。
  Future<void> runWithLoading(
    Future<void> Function() action, {
    bool allowClick = false,
    bool crossPage = true,
  }) async {
    if (_isShowingLoading) return;
    showLoading(allowClick: allowClick, crossPage: crossPage);
    try {
      await action();
    } catch (e) {
      emitHint(e.toString());
    } finally {
      hideLoading();
    }
  }

  // ===========================================================================
  // Hint
  // ===========================================================================

  /// 展示提示。
  void emitHint(String hint) {
    if (hint.trim().isEmpty) return;
    showHintHandler?.call(hint);
  }

  // ===========================================================================
  // 导航
  // ===========================================================================

  /// 关闭当前页面。
  void pop<T extends Object?>([T? result]) {
    rootNavigatorKey.currentState?.pop(result);
  }
}
