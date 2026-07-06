/// Auth 模块 —— 通用可灵活适配的认证服务。
///
/// ## 结构
///
/// ```
/// AuthSession          — session 模型（token + payload）
/// AuthStore            — 会话持久化后端
/// authSessionProvider  — 唯一响应式登录态状态源
/// AuthSessionController — 会话语义化写入口
/// ```
///
/// ## 使用
///
/// ```dart
/// // 启动恢复
/// await authStore.init();
///
/// // UI 响应式
/// ref.watch(authSessionProvider);
///
/// // 登录/退出
/// ref.read(authSessionControllerProvider).saveSession(session);
/// ref.read(authSessionControllerProvider).clearSession();
/// ```
library;

export 'auth_session.dart';
export 'auth_store.dart';
export 'auth_provider.dart';
export 'auth_session_controller.dart';
