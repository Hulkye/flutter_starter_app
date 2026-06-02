import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_manager.dart';
import 'auth_session.dart';

/// 认证会话 Provider（响应式）。
///
/// Widget 中通过 `ref.watch(authSessionProvider)` 监听登录状态。
final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSession?>(
      AuthSessionNotifier.new,
    );

class AuthSessionNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() => authManager.current;

  /// 登录成功后保存会话。
  void setSession(AuthSession session) {
    authManager.setSession(session);
    state = session;
  }

  /// 登出。
  void clear() {
    authManager.clear();
    state = null;
  }

  /// 更新 payload 中的字段。
  void updatePayload(Map<String, dynamic> updates) {
    final c = state;
    if (c == null) return;
    final updated = AuthSession(
      token: c.token,
      refreshToken: c.refreshToken,
      payload: {...c.payload, ...updates},
    );
    setSession(updated);
  }
}
