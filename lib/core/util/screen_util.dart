import 'package:flutter/widgets.dart' hide EdgeInsets, Alignment;
export 'package:flutter/material.dart' hide EdgeInsets, Alignment;

///屏幕适配
import 'package:flutter_screenutil/flutter_screenutil.dart' as flutter_screen;

class ScreenUtil {
  static double _paddingTop = 0;

  ///竖屏情况，顶部安全间隔
  static double _paddingBottom = 0;

  ///竖屏情况，底部安全间隔

  static final flutter_screen.ScreenUtil _screenUtil =
      flutter_screen.ScreenUtil();

  static double get paddingTop => _paddingTop;
  static double get paddingBottom => _paddingBottom;
  static Size? uiSize;

  ///获取竖屏情况的上下安全间距
  static void _getPaddingTopAndBottom(BuildContext context) {
    if (_screenUtil.orientation == Orientation.portrait) {
      MediaQueryData mqData = MediaQuery.of(context);
      _paddingTop = mqData.padding.top;
      _paddingBottom = mqData.padding.bottom;
    }
  }

  ///启动app，需要先进行初始化
  static Widget screenInit(Widget appWidget, Size initSize) {
    uiSize = initSize;
    Widget child = flutter_screen.ScreenUtilInit(
      designSize: initSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        _getPaddingTopAndBottom(context);
        Widget newChild = appWidget;
        if (textScaleFactor != null) {
          newChild = MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScaleFactor!)),
            child: newChild,
          );
        }

        return newChild;
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

  ///系统字体缩放比例,固定比例
  static double? get textScaleFactor => 1.0; //_screenUtil.textScaleFactor;

  ///屏幕方向
  static Orientation get orientation => _screenUtil.orientation;

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
  ///适配字体
  double get sp {
    double value;
    value = ScreenUtil._screenUtil.setSp(this);
    // 调整为根据缩放系数进行适配
    // value = this * ScreenUtil._screenUtil.textScaleFactor * 1.04;
    return value;
  }

  /// 根据宽度进行调整
  double get w {
    return ScreenUtil._screenUtil.setWidth(this);
    // return this * 1.0;
  }

  /// 根据屏幕高度适配尺寸(一般根据宽度适配即可)
  double get h {
    return ScreenUtil._screenUtil.setHeight(this);
    // return this * 1.0;
  }

  ///横屏情况，需要用高度来进行换算
  double get hw {
    return (ScreenUtil._screenUtil.screenHeight / ScreenUtil.uiSize!.width) *
        this;
    // return this * 1.0;
  }
}
