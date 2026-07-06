import 'package:flutter/services.dart';
import 'package:flutter_starter_app/header.dart';
import 'package:webview_flutter/webview_flutter.dart';

final class WebPage extends BasePage {
  const WebPage({required this.config, super.key});

  final WebPageConfig config;

  @override
  PageLogic createPageLogic() => _WebPageLogic(config);

  @override
  String title(BuildContext context) => config.title ?? context.i18n.webPage;

  @override
  bool get canPop => false;

  @override
  Future<bool> onPopInvokedWithScope(PageScope scope, dynamic result) async {
    await scope.logic<_WebPageLogic>().goBackOrClose();
    return false;
  }

  @override
  PreferredSizeWidget? appBar(PageScope scope) {
    final logic = scope.logic<_WebPageLogic>();
    return AppBar(
      leading: buildBackButton(scope),
      title: createTitleWidget(scope, logic.pageTitle(scope.context)),
      centerTitle: true,
      backgroundColor: appBarBgColor(scope.context),
      actions: appBarActions(scope),
      toolbarHeight: ScreenUtil.appBarHeight,
      systemOverlayStyle: systemOverlayStyle(scope.context),
      scrolledUnderElevation: 0,
      bottom: config.showProgress && logic.showProgress
          ? PreferredSize(
              preferredSize: Size.fromHeight(2.w),
              child: LinearProgressIndicator(
                minHeight: 2.w,
                value: logic.progress / 100,
                color: scope.context.appColor.brand,
                backgroundColor: scope.context.appColor.compBackgroundTertiary,
              ),
            )
          : null,
    );
  }

  @override
  Widget? buildBackButton(PageScope scope) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      color: appBarBackButtonColor(scope.context),
      onPressed: scope.logic<_WebPageLogic>().goBackOrClose,
    );
  }

  @override
  List<Widget> appBarActions(PageScope scope) {
    final logic = scope.logic<_WebPageLogic>();
    if (!logic.canLoad) {
      return const [];
    }
    return [
      if (config.showCloseButton && logic.canGoBackInWeb)
        IconButton(
          tooltip: scope.context.i18n.close,
          icon: const Icon(Icons.close),
          color: appBarBackButtonColor(scope.context),
          onPressed: logic.closePage,
        ),
      if (config.showToolbarActions)
        PopupMenuButton<_WebPageMenuAction>(
          tooltip: scope.context.i18n.more,
          iconColor: appBarBackButtonColor(scope.context),
          onSelected: logic.handleMenuAction,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: _WebPageMenuAction.reload,
                child: Text(context.i18n.reload),
              ),
              PopupMenuItem(
                value: _WebPageMenuAction.back,
                enabled: logic.canGoBackInWeb,
                child: Text(context.i18n.back),
              ),
              PopupMenuItem(
                value: _WebPageMenuAction.forward,
                enabled: logic.canGoForwardInWeb,
                child: Text(context.i18n.forward),
              ),
              PopupMenuItem(
                value: _WebPageMenuAction.copyLink,
                child: Text(context.i18n.copyLink),
              ),
              PopupMenuItem(
                value: _WebPageMenuAction.clearCache,
                child: Text(context.i18n.clearWebCache),
              ),
            ];
          },
        ),
    ];
  }

  @override
  Widget page(PageScope scope) {
    final logic = scope.logic<_WebPageLogic>();
    if (!logic.canLoad) {
      return _WebPageErrorView(
        message: logic.validationMessage(scope.context),
        onRetry: logic.reloadInitialUrl,
      );
    }

    return ColoredBox(
      color: scope.context.appColor.backgroundPrimary,
      child: Stack(
        children: [
          WebViewWidget(controller: logic.controller),
          if (logic.hasError)
            Positioned.fill(
              child: _WebPageErrorView(
                message: logic.errorMessage ?? scope.context.i18n.webLoadFailed,
                onRetry: logic.reloadInitialUrl,
              ),
            ),
        ],
      ),
    );
  }
}

final class _WebPageLogic extends PageLogic {
  _WebPageLogic(this.config);

  final WebPageConfig config;
  late final WebViewController controller;
  late final WebPageValidationResult _validation;

  int progress = 0;
  bool isLoading = false;
  bool hasError = false;
  bool canGoBackInWeb = false;
  bool canGoForwardInWeb = false;
  String? currentUrl;
  String? errorMessage;

  bool get canLoad => _validation == WebPageValidationResult.ok;
  bool get showProgress => isLoading && progress > 0 && progress < 100;

  @override
  void onInit() {
    _validation = config.validate();
    currentUrl = config.uri?.toString();
    if (!canLoad) return;
    controller = WebViewController(onPermissionRequest: _denyPermissionRequest)
      ..setJavaScriptMode(config.javaScriptMode)
      ..enableZoom(config.enableZoom)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(_createNavigationDelegate());
    final userAgent = config.userAgent?.trim();
    if (userAgent != null && userAgent.isNotEmpty) {
      controller.setUserAgent(userAgent);
    }
  }

  @override
  void onReady() {
    if (!canLoad) return;
    _loadInitialUrl();
  }

  String pageTitle(BuildContext context) {
    final title = config.title?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }
    return context.i18n.webPage;
  }

  String validationMessage(BuildContext context) {
    return switch (_validation) {
      WebPageValidationResult.ok => errorMessage ?? context.i18n.webLoadFailed,
      WebPageValidationResult.invalidUrl => context.i18n.webInvalidUrl,
      WebPageValidationResult.blockedHost => context.i18n.webBlockedUrl,
    };
  }

  Future<void> reloadInitialUrl() async {
    if (!canLoad) return;
    hasError = false;
    errorMessage = null;
    markNeedsBuild();
    await _loadInitialUrl();
  }

  Future<void> goBackOrClose() async {
    if (!canLoad) {
      closePage();
      return;
    }
    if (config.enableWebHistoryBack && await controller.canGoBack()) {
      await controller.goBack();
      await _syncNavigationState();
      return;
    }
    closePage();
  }

  void closePage() {
    ref.read(appRouterProvider).back();
  }

  Future<void> handleMenuAction(_WebPageMenuAction action) async {
    switch (action) {
      case _WebPageMenuAction.reload:
        await controller.reload();
      case _WebPageMenuAction.back:
        if (await controller.canGoBack()) {
          await controller.goBack();
        }
      case _WebPageMenuAction.forward:
        if (await controller.canGoForward()) {
          await controller.goForward();
        }
      case _WebPageMenuAction.copyLink:
        final url = await controller.currentUrl() ?? currentUrl ?? config.url;
        await Clipboard.setData(ClipboardData(text: url));
        presentation.emitHint(ref.read(appLocalizationsProvider).copied);
      case _WebPageMenuAction.clearCache:
        await controller.clearCache();
        await controller.clearLocalStorage();
        presentation.emitHint(
          ref.read(appLocalizationsProvider).webCacheCleared,
        );
    }
    await _syncNavigationState();
  }

  Future<void> _loadInitialUrl() async {
    final uri = config.uri;
    if (uri == null) return;
    try {
      if (config.clearCacheOnOpen) {
        await controller.clearCache();
      }
      if (config.clearLocalStorageOnOpen) {
        await controller.clearLocalStorage();
      }
      await controller.loadRequest(
        uri,
        method: config.method,
        headers: config.headers,
        body: config.body,
      );
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      presentation.emitHint(ref.read(appLocalizationsProvider).webLoadFailed);
      markNeedsBuild();
    }
  }

  NavigationDelegate _createNavigationDelegate() {
    return NavigationDelegate(
      onProgress: (value) {
        progress = value;
        isLoading = value < 100;
        markNeedsBuild();
      },
      onPageStarted: (url) {
        currentUrl = url;
        progress = 0;
        isLoading = true;
        hasError = false;
        errorMessage = null;
        markNeedsBuild();
      },
      onPageFinished: (url) async {
        currentUrl = url;
        progress = 100;
        isLoading = false;
        await _syncNavigationState();
      },
      onUrlChange: (change) {
        final url = change.url;
        if (url == null || url.isEmpty) return;
        currentUrl = url;
        markNeedsBuild();
      },
      onNavigationRequest: (request) {
        final uri = WebPageConfig.normalizeWebUri(request.url);
        if (uri == null) {
          presentation.emitHint(
            ref.read(appLocalizationsProvider).webBlockedUrl,
          );
          return NavigationDecision.prevent;
        }
        if (!WebPageConfig.isAllowedHost(uri, config.allowedHosts)) {
          presentation.emitHint(
            ref.read(appLocalizationsProvider).webBlockedUrl,
          );
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onWebResourceError: (error) {
        if (error.isForMainFrame != true) return;
        hasError = true;
        isLoading = false;
        errorMessage = error.description;
        presentation.emitHint(ref.read(appLocalizationsProvider).webLoadFailed);
        markNeedsBuild();
      },
      onHttpError: (error) {
        hasError = true;
        isLoading = false;
        errorMessage = ref.read(appLocalizationsProvider).webLoadFailed;
        presentation.emitHint(ref.read(appLocalizationsProvider).webLoadFailed);
        markNeedsBuild();
      },
      onSslAuthError: (error) {
        error.cancel();
        presentation.emitHint(ref.read(appLocalizationsProvider).webBlockedUrl);
      },
      onHttpAuthRequest: (request) {
        request.onCancel();
        presentation.emitHint(ref.read(appLocalizationsProvider).webBlockedUrl);
      },
    );
  }

  Future<void> _syncNavigationState() async {
    canGoBackInWeb = await controller.canGoBack();
    canGoForwardInWeb = await controller.canGoForward();
    markNeedsBuild();
  }

  void _denyPermissionRequest(WebViewPermissionRequest request) {
    request.deny();
    presentation.emitHint(ref.read(appLocalizationsProvider).webBlockedUrl);
  }
}

enum _WebPageMenuAction { reload, back, forward, copyLink, clearCache }

final class _WebPageErrorView extends StatelessWidget {
  const _WebPageErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColor;
    return ColoredBox(
      color: appColor.backgroundPrimary,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_outlined,
                size: 56.w,
                color: appColor.iconTertiary,
              ),
              SizedBox(height: 16.w),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appColor.fontSecondary,
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.w),
              PrimaryRoundButton(
                context: context,
                label: context.i18n.reload,
                height: 44.w,
                expand: false,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
