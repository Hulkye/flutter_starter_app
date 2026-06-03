import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';

/// 基于 EasyRefresh：iOS 使用 [CupertinoHeader]，其它平台使用 [MaterialHeader]。
///
/// 通过 [create] 返回具体 [Header] 子类，以保留各样式自带的触发距离、弹簧与摩擦等默认行为。
class AppRefreshHeader {
  AppRefreshHeader._();

  static double get _triggerOffset => 60;
  static bool get _clamping => false;

  static Header create() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoHeader(
        triggerOffset: _triggerOffset,
        clamping: _clamping,
      );
    }
    return MaterialHeader(triggerOffset: _triggerOffset, clamping: _clamping);
  }
}
