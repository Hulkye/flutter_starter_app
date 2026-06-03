import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

///加载中弹窗的控制器，保证全局只有一个正在进行显示
class LoadingController {
  static ToastCancel? _cancelFunc;
  static Widget? _loadingWidget;

  static bool get hadSet => _loadingWidget != null;
  static void setLoadingWidget(Widget loadingWidget) {
    _loadingWidget = loadingWidget;
  }

  static ToastCancel showLoading({
    bool allowClick = false,
    bool crossPage = true,
  }) {
    _cancelFunc?.call();
    final cancelFunc = ToastUtil.customDialog(
      toastBuilder: (CancelFunc cancelFunc) {
        return _loadingWidget ?? Container();
      },
      onlyOne: true,
      allowClick: allowClick,
      crossPage: crossPage,
    );
    _cancelFunc = cancelFunc;
    return cancelFunc;
  }

  static void close() {
    _cancelFunc?.call();
    _cancelFunc = null;
  }
}
