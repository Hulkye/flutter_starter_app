import 'dart:async';

/// 平台 URI 来源抽象，便于替换插件并测试冷启动和后续事件。
abstract interface class DeepLinkUriSource {
  /// 获取 App 冷启动时由平台传入的 URI。
  Future<Uri?> getInitialUri();

  /// 获取 App 已运行时收到的后续 URI 事件。
  Stream<Uri> get uriStream;

  /// 释放平台来源持有的资源。
  Future<void> dispose();
}
