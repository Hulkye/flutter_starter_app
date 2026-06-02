import 'package:flutter/material.dart';
import '../data/res_data.dart';

class AppColor extends ColorData {
  /// 品牌色
  final Color brand;

  /// 一级警示色
  final Color warning;

  /// 二级警示色
  final Color alert;

  /// 确认色
  final Color confirm;

  /// 一级文本
  final Color fontPrimary;

  /// 二级文本
  final Color fontSecondary;

  /// 三级文本
  final Color fontTertiary;

  /// 四级文本
  final Color fontFourth;

  /// 高亮文本
  final Color fontEmphasize;

  /// 一级文本反色
  final Color fontOnPrimary;

  /// 二级文本反色
  final Color fontOnSecondary;

  /// 三级文本反色
  final Color fontOnTertiary;

  /// 四级文本反色
  final Color fontOnFourth;

  /// 一级图标
  final Color iconPrimary;

  /// 二级图标
  final Color iconSecondary;

  /// 三级图标
  final Color iconTertiary;

  /// 四级图标
  final Color iconFourth;

  /// 高亮图标
  final Color iconEmphasize;

  /// 高亮辅助图标
  final Color iconSubEmphasize;

  /// 一级图标反色
  final Color iconOnPrimary;

  /// 二级图标反色
  final Color iconOnSecondary;

  /// 三级图标反色
  final Color iconOnTertiary;

  /// 四级图标反色
  final Color iconOnFourth;

  /// 一级背景（实色/不透明色）
  final Color backgroundPrimary;

  /// 二级背景（实色/不透明色）
  final Color backgroundSecondary;

  /// 三级背景（实色/不透明色）
  final Color backgroundTertiary;

  /// 四级背景（实色/不透明色）
  final Color backgroundFourth;

  /// 高亮背景（实色/不透明色）
  final Color backgroundEmphasize;

  /// 前背景
  final Color compForegroundPrimary;

  /// 白色背景
  final Color compBackgroundPrimary;

  /// 常亮背景
  final Color compBackgroundPrimaryContrary;

  /// 灰色背景
  final Color compBackgroundGray;

  /// 二级背景
  final Color compBackgroundSecondary;

  /// 三级背景
  final Color compBackgroundTertiary;

  /// 高亮背景
  final Color compBackgroundEmphasize;

  /// 黑色中性高亮背景
  final Color compBackgroundNeutral;

  /// 20%高亮背景
  final Color compEmphasizeSecondary;

  /// 10%高亮背景
  final Color compEmphasizeTertiary;

  /// 分割线颜色
  final Color compDivider;

  /// 通用反色
  final Color compCommonContrary;

  /// 获焦态背景色
  final Color compBackgroundFocus;

  /// 获焦态一级反色
  final Color compFocusedPrimary;

  /// 获焦态二级反色
  final Color compFocusedSecondary;

  /// 获焦态三级反色
  final Color compFocusedTertiary;

  /// 通用悬停交互式颜色
  final Color interactiveHover;

  /// 通用按压交互式颜色
  final Color interactivePressed;

  /// 通用获焦交互式颜色
  final Color interactiveFocus;

  /// 通用激活交互式颜色
  final Color interactiveActive;

  /// 通用选择交互式颜色
  final Color interactiveSelect;

  /// 通用点击交互式颜色
  final Color interactiveClick;

  AppColor({
    this.brand = const Color(0xFF0A59F7),
    this.warning = const Color(0xFFE84026),
    this.alert = const Color(0xFFED6F21),
    this.confirm = const Color(0xFF64BB5C),
    this.fontPrimary = const Color(0xE5000000),
    this.fontSecondary = const Color(0x99000000),
    this.fontTertiary = const Color(0x66000000),
    this.fontFourth = const Color(0x33000000),
    this.fontEmphasize = const Color(0xFF0A59F7),
    this.fontOnPrimary = const Color(0xFFFFFFFF),
    this.fontOnSecondary = const Color(0x99FFFFFF),
    this.fontOnTertiary = const Color(0x66FFFFFF),
    this.fontOnFourth = const Color(0x33FFFFFF),
    this.iconPrimary = const Color(0xE5000000),
    this.iconSecondary = const Color(0x99000000),
    this.iconTertiary = const Color(0x66000000),
    this.iconFourth = const Color(0x33000000),
    this.iconEmphasize = const Color(0xFF0A59F7),
    this.iconSubEmphasize = const Color(0x660A59F7),
    this.iconOnPrimary = const Color(0xFFFFFFFF),
    this.iconOnSecondary = const Color(0x99FFFFFF),
    this.iconOnTertiary = const Color(0x66FFFFFF),
    this.iconOnFourth = const Color(0x33FFFFFF),
    this.backgroundPrimary = const Color(0xFFFFFFFF),
    this.backgroundSecondary = const Color(0xFFF1F3F5),
    this.backgroundTertiary = const Color(0xFFE5E5EA),
    this.backgroundFourth = const Color(0xFFD1D1D6),
    this.backgroundEmphasize = const Color(0xFF0A59F7),
    this.compForegroundPrimary = const Color(0xFF000000),
    this.compBackgroundPrimary = const Color(0xFFFFFFFF),
    this.compBackgroundPrimaryContrary = const Color(0xFFFFFFFF),
    this.compBackgroundGray = const Color(0xFFF1F3F5),
    this.compBackgroundSecondary = const Color(0x19000000),
    this.compBackgroundTertiary = const Color(0x0C000000),
    this.compBackgroundEmphasize = const Color(0xFF0A59F7),
    this.compBackgroundNeutral = const Color(0xFF000000),
    this.compEmphasizeSecondary = const Color(0x330A59F7),
    this.compEmphasizeTertiary = const Color(0x190A59F7),
    this.compDivider = const Color(0x33000000),
    this.compCommonContrary = const Color(0xFFFFFFFF),
    this.compBackgroundFocus = const Color(0xFFF1F3F5),
    this.compFocusedPrimary = const Color(0xE5000000),
    this.compFocusedSecondary = const Color(0x99000000),
    this.compFocusedTertiary = const Color(0x66000000),
    this.interactiveHover = const Color(0x0C000000),
    this.interactivePressed = const Color(0x19000000),
    this.interactiveFocus = const Color(0xFF0A59F7),
    this.interactiveActive = const Color(0xFF0A59F7),
    this.interactiveSelect = const Color(0x330A59F7),
    this.interactiveClick = const Color(0x19000000),
  });
}
