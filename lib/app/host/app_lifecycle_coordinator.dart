import '../capabilities/app_capability_registry.dart';

/// App 生命周期与可选能力之间的统一桥接。
final class AppLifecycleCoordinator {
  const AppLifecycleCoordinator(this.capabilities);

  /// 当前 App 已装配的能力集合。
  final AppCapabilityRegistry capabilities;

  /// 启动所有已装配能力。
  void start() => capabilities.start();

  /// 通知 bootstrap 完成。
  void onBootstrapCompleted() => capabilities.onBootstrapCompleted();

  /// 通知认证状态变化。
  void onAuthenticationChanged() => capabilities.onAuthenticationChanged();

  /// 释放能力资源。
  Future<void> dispose() => capabilities.dispose();
}
