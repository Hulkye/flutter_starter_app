import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'auth_session.dart';

/// 认证会话控制器。
///
/// 作为 App 登录态的语义化写入口，避免业务侧直接操作
/// [AuthSessionNotifier] 的底层方法。
final class AuthSessionController {
  const AuthSessionController(this._ref);

  final Ref _ref;

  /// 保存登录成功后的会话。
  Future<void> saveSession(AuthSession session) async {
    await _ref.read(authSessionProvider.notifier).setSession(session);
  }

  /// 清空当前会话。
  Future<void> clearSession() async {
    await _ref.read(authSessionProvider.notifier).clear();
  }

  /// 更新会话 payload。
  Future<void> updatePayload(Map<String, dynamic> updates) async {
    await _ref.read(authSessionProvider.notifier).updatePayload(updates);
  }
}

/// 认证会话控制器 Provider。
final authSessionControllerProvider = Provider<AuthSessionController>((ref) {
  return AuthSessionController(ref);
});
