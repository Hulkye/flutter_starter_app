import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

/// 弹窗控制类
/// 先进先出原则
class DialogController {
  static final List<_DialogEntry> _dialogStack = []; // 管理弹窗堆栈
  static bool _isDialogShowing = false; // 是否有弹窗正在显示

  static bool get isDialogShowing => _isDialogShowing;

  static VoidCallback? _closeCallback;

  ///设置关闭的回调
  static void addCloseCallback(VoidCallback? callback) {
    _closeCallback = callback;
  }

  /// 打开弹窗
  static ToastCancel _openDialog({
    required Widget dialogWidget,
    bool clickClose = false, // 是否允许点击外部关闭
    BackButtonBehavior? backButtonBehavior, // 返回按钮行为
    Color? backgroundColor,
  }) {
    return ToastUtil.customDialog(
      toastBuilder: (cancelFunc) => dialogWidget,
      onlyOne: true, // 确保 ToastUtil 自身不重复
      crossPage: false,
      clickClose: clickClose,
      backButtonBehavior: backButtonBehavior, // 返回按钮行为
      backgroundColor: backgroundColor,
      onClose: () {
        _onDialogClosed();
      },
    );
  }

  /// 弹窗关闭时的处理逻辑
  static void _onDialogClosed() async {
    _dialogStack.removeAt(0).cancelFunc.call();
    _isDialogShowing = false; // 标记无弹窗显示
    _closeCallback?.call();
    _showNextDialog(); // 显示下一个弹窗
  }

  /// 展示弹窗
  static void showDialog({
    required Widget dialogWidget, // 接收 ToastBuilderFunc
    bool clickClose = false, // 是否允许点击外部关闭
    BackButtonBehavior? backButtonBehavior, // 返回按钮行为
    Color? backgroundColor,
    VoidCallback? cancelCallback,
  }) async {
    _dialogStack.add(
      _DialogEntry(
        dialogWidget: dialogWidget,
        clickClose: clickClose,
        backButtonBehavior: backButtonBehavior,
        backgroundColor: backgroundColor,
        cancelCallback: cancelCallback,
      ),
    );
    if (!_isDialogShowing) {
      _showNextDialog();
    }
  }

  /// 打开下一个弹窗
  static void _showNextDialog() {
    if (_dialogStack.isEmpty) {
      _isDialogShowing = false; // 队列为空，标记无弹窗
      return;
    }
    final nextDialog = _dialogStack.first;
    nextDialog.toastCancelFunc = _openDialog(
      dialogWidget: nextDialog.dialogWidget,
      clickClose: nextDialog.clickClose,
      backButtonBehavior: nextDialog.backButtonBehavior,
      backgroundColor: nextDialog.backgroundColor,
    );
    _isDialogShowing = true; // 标记当前有弹窗显示
  }

  /// 关闭当前弹窗
  /// 外部手动调用
  static void closeDialog() {
    if (_dialogStack.isEmpty) return;
    // 关闭当前弹窗
    final currentDialog = _dialogStack.first;
    currentDialog.cancelFunc.call();
  }

  /// 清空所有弹窗
  static void clearAllDialogs() {
    while (_dialogStack.isNotEmpty) {
      _dialogStack.removeAt(0).cancelFunc.call();
    }
    _isDialogShowing = false;
  }
}

class _DialogEntry {
  final Widget dialogWidget;
  final bool clickClose;
  final BackButtonBehavior? backButtonBehavior;
  final Color? backgroundColor;
  ToastCancel? toastCancelFunc;
  final VoidCallback? cancelCallback;

  void cancelFunc() {
    cancelCallback?.call();
    toastCancelFunc?.call();
  }

  _DialogEntry({
    required this.dialogWidget,
    this.clickClose = false,
    this.backButtonBehavior,
    this.backgroundColor,
    this.cancelCallback,
  });
}
