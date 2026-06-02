/// Auth 模块 —— 通用可灵活适配的认证服务。
///
/// ## 结构
///
/// ```
/// AuthSession     — session 模型（token + payload）
/// AuthManager     — 管理器（同步访问 + 持久化 + Riverpod Provider）
/// ```
///
/// ## 使用
///
/// ```dart
/// // 启动恢复
/// await authManager.init();
///
/// // UI 响应式
/// ref.watch(authSessionProvider);
///
/// // 拦截器同步读
/// authManager.bearerToken;
///
/// // 登录/登出
/// authManager.setSession(AuthSession(token: 'xxx', payload: {'userId': '1'}));
/// authManager.clear();
/// ```
library;

export 'auth_session.dart';
export 'auth_manager.dart';
export 'auth_provider.dart';
