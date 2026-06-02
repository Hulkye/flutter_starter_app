import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_state.dart';
import 'base_vm.dart';

/// 页面基类。
///
/// 泛型 [V] 为页面对应的 ViewModel 类型，须继承 [BaseVM]。
///
/// [BasePage] 只负责页面结构：Scaffold、AppBar、SafeArea、背景层、PopScope、
/// prePage/page 切换。Loading / Hint 这类一次性反馈由 [BaseVM] 直接处理。
abstract class BasePage<V extends BaseVM> extends ConsumerStatefulWidget {
  const BasePage({super.key});

  // ===========================================================================
  // VM 接入（子类必须实现）
  // ===========================================================================

  /// 获取 VM notifier（用于调用 pop、showLoading、emitHint 等操作）。
  V notifier(WidgetRef ref);

  /// 监听 state 变化（用于响应式 UI 重建）。
  BaseState watchState(WidgetRef ref);

  // ===========================================================================
  // 页面内容（子类必须实现）
  // ===========================================================================

  /// 页面主体。BasePage 自动包裹 Scaffold。
  Widget page(BuildContext context, WidgetRef ref, V vm);

  /// 数据就绪前的占位视图。
  Widget prePage(BuildContext context) {
    return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
  }

  // ===========================================================================
  // Scaffold 配置
  // ===========================================================================

  bool get showAppBar => true;
  String get title => '';
  Color backgroundColor(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  bool? get resizeToAvoidBottomInset => null;

  // ===========================================================================
  // AppBar
  // ===========================================================================

  Widget? buildBackButton(BuildContext context, WidgetRef ref, V vm) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => vm.pop(),
    );
  }

  List<Widget> appBarActions(BuildContext context, WidgetRef ref) => const [];

  PreferredSizeWidget? appBar(BuildContext context, WidgetRef ref, V vm) {
    if (!showAppBar) return null;
    return AppBar(
      leading: buildBackButton(context, ref, vm),
      title: title.isNotEmpty ? Text(title) : null,
      actions: appBarActions(context, ref),
      systemOverlayStyle: systemOverlayStyle(context),
    );
  }

  // ===========================================================================
  // Overlay / 背景 / SafeArea
  // ===========================================================================

  SystemUiOverlayStyle? systemOverlayStyle(BuildContext context) => null;
  List<Widget> backgroundWidgets(BuildContext context) => const [];

  bool get safeAreaTop => false;
  bool get safeAreaBottom => false;
  bool get maintainBottomViewPadding => false;

  // ===========================================================================
  // Scaffold 元素
  // ===========================================================================

  Widget? floatingActionButton(BuildContext context, WidgetRef ref, V vm) =>
      null;
  FloatingActionButtonLocation? get floatingActionButtonLocation => null;
  Widget? bottomNavigationBar(BuildContext context) => null;

  // ===========================================================================
  // 返回拦截
  // ===========================================================================

  bool get canPop => true;
  Future<bool> onPopInvoked(dynamic result) async => true;

  // ===========================================================================
  // 其他
  // ===========================================================================

  bool get keepAlive => false;

  void onBackgroundTap(BuildContext context, WidgetRef ref, V vm) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ===========================================================================
  // 外层包装
  // ===========================================================================

  /// 页面外层结构，默认返回 Scaffold。
  Widget wrap(BuildContext context, WidgetRef ref, V vm, Widget body) {
    Widget child = Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar(context, ref, vm),
      body: body,
      backgroundColor: backgroundColor(context),
      floatingActionButton: floatingActionButton(context, ref, vm),
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar(context),
    );

    final bgWidgets = backgroundWidgets(context);
    if (bgWidgets.isNotEmpty) {
      child = Stack(
        children: [
          ...bgWidgets,
          Positioned.fill(child: child),
        ],
      );
    }

    final overlay = systemOverlayStyle(context);
    if (overlay != null) {
      child = AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: child,
      );
    }

    child = SafeArea(
      top: safeAreaTop,
      bottom: safeAreaBottom,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );

    return child;
  }

  @override
  ConsumerState<BasePage<V>> createState() => _BasePageState<V>();
}

class _BasePageState<V extends BaseVM> extends ConsumerState<BasePage<V>>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _readyCalled = false;
  bool _paused = false;
  V? _vm;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _readyCalled) return;
      _readyCalled = true;
      final vm = _vm;
      if (vm == null) return;
      vm.onReady();
      vm.onResume();
      _paused = false;
    });
  }

  @override
  void dispose() {
    final vm = _vm;
    if (vm != null) {
      vm.onClose();
      if (!_paused) {
        vm.onPause();
        _paused = true;
      }
    }
    _vm = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = _vm;
    if (vm == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (_paused) {
          vm.onResume();
          _paused = false;
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (!_paused) {
          vm.onPause();
          _paused = true;
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final state = widget.watchState(ref);
    final vm = widget.notifier(ref);
    _vm = vm;

    final body = state.isReady
        ? widget.page(context, ref, vm)
        : widget.prePage(context);

    Widget child = widget.wrap(context, ref, vm, body);

    child = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.onBackgroundTap(context, ref, vm),
      child: child,
    );

    child = PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final ok = await widget.onPopInvoked(result);
        if (ok && mounted) {
          vm.pop(result);
        }
      },
      child: child,
    );

    return child;
  }
}
