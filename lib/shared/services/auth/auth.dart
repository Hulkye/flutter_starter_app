/// Auth 模块 —— 通用可灵活适配的认证服务。
///
/// ## 结构
///
/// ```
/// AuthSession          — session 模型（token + payload）
/// AuthStore            — 会话持久化后端
/// authSessionProvider  — 唯一登录态读取与业务写入口
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
/// // 登录/登出
/// ref.read(authSessionProvider.notifier).setSession(session);
/// ref.read(authSessionProvider.notifier).clear();
/// ```
library;

export 'auth_session.dart';
export 'auth_store.dart';
export 'auth_provider.dart';
