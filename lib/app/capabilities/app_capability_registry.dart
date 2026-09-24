import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/capability/app_capability.dart';

/// App 级可选能力的统一生命周期注册表。
///
/// 这里只管理生命周期广播，不了解 Deep Link、Push 或其他具体能力的业务语义。
final class AppCapabilityRegistry {
  const AppCapabilityRegistry({this.capabilities = const <AppCapability>[]});

  /// 当前 App 已装配的可选能力。
  final List<AppCapability> capabilities;

  /// 启动已装配的可选能力。
  void start() {
    for (final capability in capabilities) {
      capability.start();
    }
  }

  /// 通知所有能力 bootstrap 已完成。
  void onBootstrapCompleted() {
    for (final capability in capabilities) {
      capability.onBootstrapCompleted();
    }
  }

  /// 通知所有能力认证状态发生变化。
  void onAuthenticationChanged() {
    for (final capability in capabilities) {
      capability.onAuthenticationChanged();
    }
  }

  /// 释放所有已装配能力。
  Future<void> dispose() async {
    for (final capability in capabilities) {
      await capability.dispose();
    }
  }
}

/// App 能力注册表 Provider。
final appCapabilityRegistryProvider = Provider<AppCapabilityRegistry>(
  (ref) => const AppCapabilityRegistry(),
);
