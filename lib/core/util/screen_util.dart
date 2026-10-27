import 'package:flutter/widgets.dart' hide EdgeInsets, Alignment;
export 'package:flutter/material.dart' hide EdgeInsets, Alignment;

///屏幕适配
import 'package:flutter_screenutil/flutter_screenutil.dart' as flutter_screen;

enum AppScreenSizeClass {
  /// 紧凑布局：屏幕宽度小于 600 逻辑像素。
  compact,

  /// 中等布局：屏幕宽度为 600 至 840 逻辑像素。
  medium,

  /// 扩展布局：屏幕宽度不小于 840 逻辑像素。
  expanded,
}

class ScreenUtil {
  static double _maxScaleFactor = 1.04;

  static double _paddingTop = 0;

  ///竖屏情况，顶部安全间隔
  static double _paddingBottom = 0;

  ///竖屏情况，底部安全间隔

  static final flutter_screen.ScreenUtil _screenUtil =
      flutter_screen.ScreenUtil();

  static double get paddingTop => _paddingTop;
  static double get paddingBottom => _paddingBottom;
  static Size? uiSize;
  static double get maxScaleFactor => _maxScaleFactor;

  ///获取竖屏情况的上下安全间距
  static void _getPaddingTopAndBottom(BuildContext context) {
    final mqData = MediaQuery.of(context);
    _paddingTop = mqData.padding.top;
    _paddingBottom = mqData.padding.bottom;
  }

  ///启动app，需要先进行初始化
  static Widget screenInit(
    Widget appWidget,
    Size initSize, {
    double maxScaleFactor = 1.04,
  }) {
    if (!maxScaleFactor.isFinite || maxScaleFactor < 1) {
      throw ArgumentError.value(
        maxScaleFactor,
        'maxScaleFactor',
        'Must be a finite number greater than or equal to 1.',
      );
    }
    uiSize = initSize;
    _maxScaleFactor = maxScaleFactor;
    Widget child = flutter_screen.ScreenUtilInit(
      designSize: initSize,
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        _getPaddingTopAndBottom(context);
        return appWidget;
      },
    );
    return child;
  }

  /// appBar高度
  static double get appBarHeight => 44;

  ///设备的像素密度
  static double? get pixelRatio => _screenUtil.pixelRatio;

  ///设备宽度
  static double get screenWidth => _screenUtil.screenWidth;

  ///设备高度
  static double get screenHeight => _screenUtil.screenHeight;

  ///底部安全区距离，适用于全面屏下面有按键的
  static double get bottomBarHeight => _screenUtil.bottomBarHeight;

  ///状态栏高度 刘海屏会更高
  static double get statusBarHeight => _screenUtil.statusBarHeight;

  ///系统文字缩放比例，由系统辅助功能设置决定。
  static double get textScaleFactor => _screenUtil.textScaleFactor;

  ///屏幕方向
  static Orientation get orientation => _screenUtil.orientation;

  /// Material 断点：compact < 600，medium < 840，expanded >= 840 逻辑像素。
  static AppScreenSizeClass get sizeClass {
    if (screenWidth < 600) return AppScreenSizeClass.compact;
    if (screenWidth < 840) return AppScreenSizeClass.medium;
    return AppScreenSizeClass.expanded;
  }

  static bool get isCompact => sizeClass == AppScreenSizeClass.compact;
  static bool get isMedium => sizeClass == AppScreenSizeClass.medium;
  static bool get isExpanded => sizeClass == AppScreenSizeClass.expanded;

  static double get pageHeight => screenHeight - statusBarHeight - appBarHeight;

  static double get topHeight => statusBarHeight + appBarHeight;

  ///24.sp  适配字体
  ///200.r 根据宽度或高度中的较小者进行调整
  ///200.h 根据屏幕高度适配尺寸(一般根据宽度适配即可)
  ///540.w 根据屏幕宽度适配尺寸
  ///12.sm 取12和12.sp中的最小值
  ///0.2.sw 屏幕宽度的0.2倍
  ///0.5.sh 屏幕高度的50%
  ///20.setVerticalSpacing  SizedBox(height: 20 * scaleHeight)
  ///20.horizontalSpace  SizedBox(height: 20 * scaleWidth)
}

extension AppSizeExtension on num {
  double _limitScale(double value) {
    final maxMagnitude = toDouble().abs() * ScreenUtil.maxScaleFactor;
    final scaledMagnitude = value.abs();
    final magnitude = scaledMagnitude < maxMagnitude
        ? scaledMagnitude
        : maxMagnitude;
    return isNegative ? -magnitude : magnitude;
  }

  /// 系统字体缩放适配
  double get sp => ScreenUtil._screenUtil.setSp(this);

  /// 基于 [sp]，并限制大屏放大比例
  double get spm => _limitScale(sp);

  /// 按屏幕宽度适配，。
  double get w => ScreenUtil._screenUtil.setWidth(this);

  /// 基于 [w]，并限制大屏放大比例
  double get wm => _limitScale(w);

  /// 按屏幕高度适配，
  double get h => ScreenUtil._screenUtil.setHeight(this);

  /// 基于 [h]，并限制大屏放大比例。
  double get hm => _limitScale(h);

  /// 屏幕宽度的比例，例如 0.2.sw 表示屏幕宽度的 20%。
  double get sw => ScreenUtil.screenWidth * this;

  /// 屏幕高度的比例，例如 0.5.sh 表示屏幕高度的 50%。
  double get sh => ScreenUtil.screenHeight * this;

  ///横屏情况，需要用高度来进行换算
  double get hw =>
      (ScreenUtil._screenUtil.screenHeight / ScreenUtil.uiSize!.width) * this;
}
