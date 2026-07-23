import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_state.dart';

/// ViewModel 基类。
///
/// 泛型 [S] 为页面状态类型，须继承 [BaseState]。
///
/// ViewModel 只负责管理状态与业务动作，不感知页面生命周期。
abstract class BaseVM<S extends BaseState> extends Notifier<S> {
  @override
  S build() => initialState();

  /// 子类返回初始状态。
  S initialState();
}

/// 页面级 ViewModel 基类。
///
/// 用于不需要跨页面保留状态的页面，最后一个监听者移除后由 Riverpod 自动销毁。
abstract class BaseAutoDisposeVM<S extends BaseState>
    extends AutoDisposeNotifier<S> {
  @override
  S build() => initialState();

  /// 子类返回初始状态。
  S initialState();
}
