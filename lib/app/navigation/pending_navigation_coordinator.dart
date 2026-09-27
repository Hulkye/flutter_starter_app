import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_navigation_command.dart';
import '../../core/router/router.dart';
import '../../shared/services/auth/auth.dart';

/// 管理需要等待 App bootstrap 或认证完成后才能执行的导航命令。
///
/// 该协调器属于 App 导航层，而不是某个外部能力。Deep Link、Push 和 OAuth
/// 都可以提交命令，从而避免 AppCapabilityRegistry 为每种能力添加类型特判。
final class PendingNavigationCoordinator {
  PendingNavigationCoordinator({
    required this.read,
    required this.requestAuthentication,
  });

  final ProviderListenableReader read;
  final void Function() requestAuthentication;

  AppNavigationCommand? _pendingCommand;
  bool _bootstrapCompleted = false;

  /// 提交新的待处理命令；后提交的命令替换尚未执行的命令。
  void submit(AppNavigationCommand command) {
    _pendingCommand = command;
    dispatchIfReady();
  }

  /// 标记 App bootstrap 完成，并尝试消费待处理命令。
  bool onBootstrapCompleted() {
    _bootstrapCompleted = true;
    return dispatchIfReady();
  }

  /// 认证状态变化后再次尝试消费命令。
  void onAuthenticationChanged() => dispatchIfReady();

  /// 如果已满足 bootstrap 和认证条件，则执行一次导航。
  bool dispatchIfReady() {
    if (!_bootstrapCompleted) return false;
    final command = _pendingCommand;
    if (command == null) return false;

    final authenticated = read(authSessionProvider)?.isValid == true;
    if (command.requiresAuthentication && !authenticated) {
      requestAuthentication();
      return false;
    }

    _pendingCommand = null;
    read(appRouterProvider).replaceAll(command.location, extra: command.extra);
    return true;
  }
}

typedef ProviderListenableReader =
    T Function<T>(ProviderListenable<T> provider);

/// PendingNavigationCoordinator 的默认装配点。
///
/// App 组合层必须通过 [createPendingNavigationOverride] 提供认证失败后的
/// 登录跳转策略。默认 Provider 允许无外部入口的宿主读取协调器，但不会掩盖
/// 缺少认证导航装配的问题。
final pendingNavigationCoordinatorProvider =
    Provider<PendingNavigationCoordinator>(
      (ref) => PendingNavigationCoordinator(
        read: ref.read,
        requestAuthentication: () {
          throw StateError(
            'PendingNavigationCoordinator requires an App composition '
            'override. Call createPendingNavigationOverride().',
          );
        },
      ),
    );

/// 由 App 组合层注入真实的认证跳转策略。
Override createPendingNavigationOverride({
  required void Function(Ref ref) requestAuthentication,
}) {
  return pendingNavigationCoordinatorProvider.overrideWith(
    (ref) => PendingNavigationCoordinator(
      read: ref.read,
      requestAuthentication: () => requestAuthentication(ref),
    ),
  );
}
