import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

///处理中弹窗的控制器，保证全局只有一个正在进行显示
class TipsController {
  static ToastCancel? _cancelFunc;
  static Widget? _tipsWidget;

  static bool get hadSet => _tipsWidget != null;
  static void setTipsWidget(Widget tipsWidget) {
    _tipsWidget = tipsWidget;
  }

  static ToastCancel showTips({
    bool allowClick = false,
    bool crossPage = true,
    Duration? duration,
  }) {
    _cancelFunc?.call();
    final cancelFunc = ToastUtil.customDialog(
      duration: duration ?? Duration(seconds: 2),
      toastBuilder: (CancelFunc cancelFunc) {
        return _tipsWidget ?? Container();
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
