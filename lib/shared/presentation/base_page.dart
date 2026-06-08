import 'package:flutter/services.dart';
import 'package:flutter_starter_app/header.dart';

/// 页面上下文。
final class PageScope {
  const PageScope({required this.context, required this.ref, this.pageLogic});

  final BuildContext context;
  final WidgetRef ref;
  final PageLogic? pageLogic;

  T logic<T extends PageLogic>() {
    final logic = pageLogic;
    if (logic is T) return logic;
    throw StateError('Page logic is not mounted as $T');
  }
}

/// 可挂载到 [BasePage] 的页面逻辑。
///
/// 用于承载页面本地 controller、临时交互状态、生命周期，以及调用 VM/Provider。
/// 页面 UI 结构、Widget 组合、布局和样式仍由 [BasePage] 子类负责。
abstract class PageLogic {
  late PageScope _scope;
  late VoidCallback _markNeedsBuild;
  bool _mounted = false;

  PageScope get scope => _scope;
  BuildContext get context => _scope.context;
  WidgetRef get ref => _scope.ref;
  bool get mounted => _mounted;

  void onInit() {}
  void onReady() {}
  void onResume() {}
  void onPause() {}
  void onDispose() {}

  void setState(VoidCallback action) {
    if (!_mounted) return;
    action();
    _markNeedsBuild();
  }

  void markNeedsBuild() {
    if (!_mounted) return;
    _markNeedsBuild();
  }

  void postFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mounted) return;
      action();
    });
  }

  void _mount(PageScope scope, VoidCallback markNeedsBuild) {
    _scope = scope;
    _markNeedsBuild = markNeedsBuild;
    _mounted = true;
    onInit();
  }

  void _updateScope(PageScope scope) {
    _scope = scope;
  }

  void _unmount() {
    if (!_mounted) return;
    onDispose();
    _mounted = false;
  }
}

/// 页面基类。
///
/// [BasePage] 只负责 UI 结构、Widget 组合、布局和样式，不绑定具体 ViewModel。
abstract class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  // ===========================================================================
  // 页面内容（子类必须实现）
  // ===========================================================================

  /// 页面主体。BasePage 自动包裹 Scaffold。
  Widget page(PageScope scope);

  /// 创建页面逻辑。需要 controller/搜索词/临时交互状态或页面生命周期时可覆盖。
  PageLogic? createPageLogic() => null;

  // ===========================================================================
  // Scaffold 配置
  // ===========================================================================

  bool get showAppBar => true;

  String title(BuildContext context) => '';

  Color backgroundColor(BuildContext context) =>
      context.appColor.backgroundPrimary;

  bool? get resizeToAvoidBottomInset => null;

  Color appBarBgColor(BuildContext context) =>
      context.appColor.backgroundPrimary;

  Color appBarTitleColor(BuildContext context) => context.appColor.fontPrimary;

  Color appBarBackButtonColor(BuildContext context) =>
      context.appColor.fontPrimary;

  // ===========================================================================
  // AppBar
  // ===========================================================================

  Widget? buildBackButton(PageScope scope) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      color: appBarBackButtonColor(scope.context),
      onPressed: () => scope.ref.read(appRouterProvider).back(),
    );
  }

  List<Widget> appBarActions(PageScope scope) => const [];

  PreferredSizeWidget? appBar(PageScope scope) {
    if (!showAppBar) return null;
    return AppBar(
      leading: buildBackButton(scope),
      title: createTitleWidget(scope),
      centerTitle: true,
      backgroundColor: appBarBgColor(scope.context),
      actions: appBarActions(scope),
      toolbarHeight: ScreenUtil.appBarHeight,
      systemOverlayStyle: systemOverlayStyle(scope.context),
      scrolledUnderElevation: 0,
    );
  }

  Widget createTitleWidget(PageScope scope, [String? titleStr]) {
    return Text(
      titleStr ?? title(scope.context),
      style: TextStyle(
        fontSize: 17.sp,
        color: appBarTitleColor(scope.context),
        fontWeight: FontWeight.bold,
      ),
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

  Widget addSafeArea(
    Widget child, {
    bool top = false,
    bool bottom = false,
    bool maintainBottomViewPadding = false,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }

  // ===========================================================================
  // Scaffold 元素
  // ===========================================================================

  Widget? floatingActionButton(PageScope scope) => null;
  FloatingActionButtonLocation? get floatingActionButtonLocation => null;
  Widget? bottomNavigationBar(PageScope scope) => null;

  // ===========================================================================
  // 返回拦截
  // ===========================================================================

  bool get canPop => true;
  Future<bool> onPopInvoked(dynamic result) async => true;

  // ===========================================================================
  // 其他
  // ===========================================================================

  bool get keepAlive => false;

  void onBackgroundTap(PageScope scope) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ===========================================================================
  // 外层包装
  // ===========================================================================

  /// 页面外层结构，默认返回 Scaffold。
  Widget wrap(PageScope scope, Widget body) {
    Widget child = Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar(scope),
      body: body,
      backgroundColor: backgroundColor(scope.context),
      floatingActionButton: floatingActionButton(scope),
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar(scope),
    );

    final bgWidgets = backgroundWidgets(scope.context);
    if (bgWidgets.isNotEmpty) {
      child = Stack(
        children: [
          ...bgWidgets,
          Positioned.fill(child: child),
        ],
      );
    }

    final overlay = systemOverlayStyle(scope.context);
    if (overlay != null) {
      child = AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: child,
      );
    }

    child = addSafeArea(
      child,
      top: safeAreaTop,
      bottom: safeAreaBottom,
      maintainBottomViewPadding: maintainBottomViewPadding,
    );

    return child;
  }

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final PageLogic? _pageLogic;
  bool _readyCalled = false;
  bool _paused = false;
  PageScope? _scope;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    _pageLogic = widget.createPageLogic();
    final scope = _createScope();
    _scope = scope;
    _pageLogic?._mount(scope, _markNeedsBuild);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _readyCalled) return;
      final scope = _scope;
      if (scope == null) return;
      _readyCalled = true;
      _pageLogic?.onReady();
      _pageLogic?.onResume();
      _paused = false;
    });
  }

  @override
  void dispose() {
    final scope = _scope;
    if (scope != null) {
      if (!_paused) {
        _pageLogic?.onPause();
        _paused = true;
      }
    }
    _pageLogic?._unmount();
    _scope = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final scope = _scope;
    if (scope == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        if (_paused) {
          _pageLogic?.onResume();
          _paused = false;
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (!_paused) {
          _pageLogic?.onPause();
          _paused = true;
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  PageScope _createScope() {
    return PageScope(context: context, ref: ref, pageLogic: _pageLogic);
  }

  void _markNeedsBuild() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final scope = _createScope();
    _scope = scope;
    _pageLogic?._updateScope(scope);

    Widget child = widget.wrap(scope, widget.page(scope));

    child = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.onBackgroundTap(scope),
      child: child,
    );

    child = PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final ok = await widget.onPopInvoked(result);
        if (ok && mounted) {
          ref.read(appRouterProvider).back(result);
        }
      },
      child: child,
    );

    return child;
  }
}
