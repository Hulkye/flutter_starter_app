import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

/// 轻提示控制器，保证全局只有一个正在进行显示
class ToastController {
  static ToastCancel? _cancelFunc;
  static Widget? _toastWidget;

  // static bool get hadSet => _toastWidget != null;
  static void setToastWidget(Widget toastWidget) {
    _toastWidget = toastWidget;
  }

  static ToastCancel showToast({
    bool clickClose = false,
    bool crossPage = true,
  }) {
    _cancelFunc?.call();
    final cancelFunc = ToastUtil.customToast(
      toastBuilder: (CancelFunc cancelFunc) {
        return _toastWidget!;
      },
      onlyOne: true,
      clickClose: clickClose,
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
