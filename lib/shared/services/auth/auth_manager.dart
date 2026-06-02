import '../../../core/storage/storage_provider.dart';
import 'auth_session.dart';

/// 认证会话管理器。
///
/// ## 职责
///
/// - 内存中持有当前会话（供拦截器/守卫同步读取 token）
/// - 与 SecureStorage 交互实现持久化
/// - 通过 [authSessionProvider] 提供 Riverpod 响应式状态
///
/// ## 使用
///
/// ```dart
/// // 启动恢复
/// await authManager.init();
///
/// // UI 响应式监听
/// ref.watch(authSessionProvider);
///
/// // 拦截器同步读 token
/// authManager.bearerToken;
///
/// // 登录保存 / 登出清除
/// authManager.setSession(session);
/// authManager.clear();
/// ```
class AuthManager {
  AuthManager({String storageKey = 'auth_session'})
      : _storageKey = storageKey;

  final String _storageKey;
  AuthSession? _current;

  // ---- 同步访问 ----

  AuthSession? get current => _current;
  bool get isAuthenticated => _current?.isValid == true;
  String? get token => _current?.token;
  String? get bearerToken => _current?.bearerToken;

  // ---- 持久化操作 ----

  /// 从安全存储恢复会话。
  Future<void> init() async {
    final raw = await secureStorage.readString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final session = AuthSession.fromJsonString(raw);
      _current = session.isValid ? session : null;
    } catch (_) {
      _current = null;
    }
  }

  /// 保存会话并持久化。
  Future<void> setSession(AuthSession session) async {
    _current = session;
    await secureStorage.setString(_storageKey, session.toJsonString());
  }

  /// 清除会话。
  Future<void> clear() async {
    _current = null;
    await secureStorage.remove(_storageKey);
  }
}

/// 全局实例（ProviderScope 前由 AppBootstrap 初始化）。
final authManager = AuthManager();
