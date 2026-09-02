/// App 可选能力的稳定生命周期协议。
///
/// App 组合层只依赖此协议，不依赖具体集成、平台插件或协调器实现。
abstract interface class AppCapability {
  /// 开始接收平台链接事件。
  void start();

  /// 通知能力 App bootstrap 已完成。
  void onBootstrapCompleted();

  /// 通知能力认证状态发生变化。
  void onAuthenticationChanged();

  /// 释放平台事件和其他资源。
  Future<void> dispose();
}

/// App 可选深链能力协议。
abstract interface class DeepLinkCapability implements AppCapability {
  /// 登录成功后尝试消费一次待处理命令。
  bool dispatchAuthenticatedCommand();
}
