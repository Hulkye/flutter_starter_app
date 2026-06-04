import 'package:flutter/services.dart';
import 'package:flutter_starter_app/header.dart';

/// 页面上下文。
final class PageScope {
  const PageScope({required this.context, required this.ref});

  final BuildContext context;
  final WidgetRef ref;
}

/// 页面基类。
///
/// [BasePage] 只负责页面结构：Scaffold、AppBar、SafeArea、背景层、PopScope
/// 以及 Widget/App 生命周期，不绑定具体 ViewModel。
abstract class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  // ===========================================================================
  // 页面内容（子类必须实现）
  // ===========================================================================

  /// 页面主体。BasePage 自动包裹 Scaffold。
  Widget page(PageScope scope);

  // ===========================================================================
  // Scaffold 配置
  // ===========================================================================

  bool get showAppBar => true;

  String get title => '';

  Color backgroundColor(BuildContext context) =>
      context.appColor.backgroundPrimary;

  bool? get resizeToAvoidBottomInset => null;

  Color appBarBgColor(BuildContext context) =>
      context.appColor.backgroundPrimary;

  Color appBarTitleColor(BuildContext context) => context.appColor.fontPrimary;

  // ===========================================================================
  // AppBar
  // ===========================================================================

  Widget? buildBackButton(PageScope scope) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => scope.ref.read(appRouterProvider).back(),
    );
  }

  List<Widget> appBarActions(PageScope scope) => const [];

  PreferredSizeWidget? appBar(PageScope scope) {
    if (!showAppBar) return null;
    return AppBar(
      leading: buildBackButton(scope),
      title: createTitleWidget(scope),
      backgroundColor: appBarBgColor(scope.context),
      actions: appBarActions(scope),
      systemOverlayStyle: systemOverlayStyle(scope.context),
    );
  }

  Widget createTitleWidget(PageScope scope, [String? titleStr]) {
    return Text(
      titleStr ?? title,
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
  // 生命周期
  // ===========================================================================

  void onPageReady(PageScope scope) {}
  void onPageResume(PageScope scope) {}
  void onPagePause(PageScope scope) {}
  void onPageClose(PageScope scope) {}

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
  bool _readyCalled = false;
  bool _paused = false;
  PageScope? _scope;

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _readyCalled) return;
      final scope = _scope;
      if (scope == null) return;
      _readyCalled = true;
      widget.onPageReady(scope);
      widget.onPageResume(scope);
      _paused = false;
    });
  }

  @override
  void dispose() {
    final scope = _scope;
    if (scope != null) {
      widget.onPageClose(scope);
      if (!_paused) {
        widget.onPagePause(scope);
        _paused = true;
      }
    }
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
          widget.onPageResume(scope);
          _paused = false;
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (!_paused) {
          widget.onPagePause(scope);
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

    final scope = PageScope(context: context, ref: ref);
    _scope = scope;

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
