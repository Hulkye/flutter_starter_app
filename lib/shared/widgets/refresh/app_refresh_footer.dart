import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';

/// 基于 EasyRefresh：iOS 使用 [CupertinoFooter]，其它平台使用 [MaterialFooter]。
///
/// 通过 [create] 返回具体 [Footer] 子类，以保留各样式自带的触发距离、弹簧与摩擦等默认行为。
class AppRefreshFooter {
  AppRefreshFooter._();

  static double get _triggerOffset => 60;
  static bool get _clamping => false;

  static Footer create() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoFooter(
        triggerOffset: _triggerOffset,
        clamping: _clamping,
      );
    }
    return MaterialFooter(triggerOffset: _triggerOffset, clamping: _clamping);
  }
}
