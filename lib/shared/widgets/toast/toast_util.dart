import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

typedef ToastCancel = void Function();
typedef ToastBuilderFunc = Widget Function(CancelFunc cancelFunc);
typedef ToastWrapAnimation =
    Widget Function(
      AnimationController controller,
      CancelFunc cancelFunc,
      Widget widget,
    );

/// 注意，颜色，字体等不能通过const定义
// 默认-展现持续时长
const _defDuration = Duration(seconds: 2);
const _defNotificationDuration = Duration(seconds: 3);
// 默认-出现动画时长
const int _defAnimationTime = 300;
const _defAnimationDuration = Duration(milliseconds: _defAnimationTime);
// 默认-消失动画时长
const _defAnimationReverseTime = 400;
const _defAnimationReverseDuration = Duration(
  milliseconds: _defAnimationReverseTime,
);
// 默认-ToastContent区域在MainContent区域的对齐
const _defAlign = Alignment(0, 0.7);
const _defNotificationAlign = Alignment(0, 0.7);
// 默认-能否正常点击遮罩下触发事件
const _defAllowClick = false;
// 默认-是否在点击屏幕触发事件时自动关闭该Toast
const _defClickClose = false;
// 默认-同一时间只能存在一个toast
const _defOnlyOne = true;
// 默认是否跨页面显示
const _defCrossPage = false;
// 默认背景色
const _defBgColor = Colors.transparent;

// 默认动画 - 弹窗
Widget _dialogWrapToastAnimation(
  AnimationController controller,
  CancelFunc cancelFunc,
  Widget child,
) {
  return FadeTransition(
    opacity: controller,
    child: ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      child: child,
    ),
  );
}

// 默认动画 - 弹窗
Widget _dialogWrapAnimation(
  AnimationController controller,
  CancelFunc cancelFunc,
  Widget child,
) {
  return FadeTransition(opacity: controller, child: child);
}

// 默认动画 - 通知
Widget _notificationWrapAnimation(
  AnimationController controller,
  CancelFunc cancelFunc,
  Widget child,
) {
  // 滑动动画（从右到左滑入）
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 从屏幕右侧开始
      end: Offset.zero, // 到屏幕内
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
    child: child,
  );
}

// 默认动画 - 通知
Widget _notificationWrapToastAnimation(
  AnimationController controller,
  CancelFunc cancelFunc,
  Widget child,
) {
  // 透明度动画（淡出效果）
  return FadeTransition(
    opacity: CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    child: child,
  );
}

class ToastUtil {
  static final initBuilder = BotToastInit();

  static final navigatorObserver = BotToastNavigatorObserver();

  static int get animationReverseTime => _defAnimationReverseTime;

  /// 自定义的文字toast
  static ToastCancel customToast({
    required ToastBuilderFunc toastBuilder,
    bool onlyOne = _defOnlyOne,
    bool crossPage = _defCrossPage,
    bool clickClose = _defClickClose,
    Alignment align = _defAlign,
    BackButtonBehavior? backButtonBehavior,
  }) {
    return BotToast.showCustomText(
      duration: _defDuration,
      animationDuration: _defAnimationDuration,
      animationReverseDuration: _defAnimationReverseDuration,
      onlyOne: onlyOne,
      crossPage: crossPage,
      clickClose: clickClose,
      align: align,
      backgroundColor: _defBgColor,
      backButtonBehavior: backButtonBehavior,
      toastBuilder: toastBuilder,
    );
  }

  /// 自定义弹窗
  static ToastCancel customDialog({
    required ToastBuilderFunc toastBuilder,
    bool onlyOne = _defOnlyOne,
    bool allowClick = _defAllowClick,
    bool crossPage = _defCrossPage,
    bool clickClose = _defClickClose,
    BackButtonBehavior? backButtonBehavior,
    VoidCallback? onClose,
    Color? backgroundColor,
    Duration? duration,
  }) {
    return BotToast.showAnimationWidget(
      duration: duration,
      animationDuration: _defAnimationDuration,
      animationReverseDuration: _defAnimationReverseDuration,
      wrapAnimation: _dialogWrapAnimation,
      wrapToastAnimation: _dialogWrapToastAnimation,
      onlyOne: onlyOne,
      crossPage: crossPage,
      clickClose: clickClose,
      allowClick: allowClick,
      backButtonBehavior: backButtonBehavior,
      toastBuilder: toastBuilder,
      onClose: onClose,
      backgroundColor: backgroundColor ?? _defBgColor,
    );
  }

  ///toast显示
  static ToastCancel showText(String hint) {
    return BotToast.showText(text: hint);
  }

  /// 自定义弹窗
  static ToastCancel customNotification({
    required ToastBuilderFunc toastBuilder,
    Duration duration = _defNotificationDuration,
    bool onlyOne = _defOnlyOne,
    bool crossPage = _defCrossPage,
    Alignment? align = _defNotificationAlign,
    VoidCallback? onClose,
    BackButtonBehavior? backButtonBehavior,
  }) {
    return BotToast.showCustomNotification(
      duration: duration,
      animationDuration: _defAnimationDuration,
      animationReverseDuration: _defAnimationReverseDuration,
      wrapAnimation: _notificationWrapAnimation,
      wrapToastAnimation: _notificationWrapToastAnimation,
      onlyOne: onlyOne,
      crossPage: crossPage,
      align: align,
      backButtonBehavior: backButtonBehavior,
      toastBuilder: toastBuilder,
      onClose: onClose,
    );
  }

  /// 自定义弹窗
  static ToastCancel customAttachedWidget({
    required ToastBuilderFunc attachedBuilder,
    BuildContext? targetContext,
    Offset? target,
    Color? backgroundColor,
    double? verticalOffset,
    double? horizontalOffset,
    PreferDirection? preferDirection,
    Duration? duration,
    bool onlyOne = _defOnlyOne,
    bool allowClick = _defAllowClick,
    VoidCallback? onClose,
    ToastWrapAnimation? wrapAnimation,
    ToastWrapAnimation? wrapToastAnimation,
  }) {
    return BotToast.showAttachedWidget(
      attachedBuilder: attachedBuilder,
      targetContext: targetContext,
      target: target,
      backgroundColor: backgroundColor ?? Colors.transparent,
      duration: duration,
      verticalOffset: verticalOffset ?? 0.0,
      horizontalOffset: horizontalOffset ?? 0.0,
      animationDuration: _defAnimationDuration,
      animationReverseDuration: _defAnimationReverseDuration,
      preferDirection: preferDirection,
      wrapAnimation: wrapAnimation,
      wrapToastAnimation: wrapToastAnimation,
      onlyOne: onlyOne,
      allowClick: allowClick,
      onClose: onClose,
    );
  }
}
