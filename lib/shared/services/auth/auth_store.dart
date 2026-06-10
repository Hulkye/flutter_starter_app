import '../../../core/storage/storage_provider.dart';
import 'auth_session.dart';

/// 认证会话存储。
///
/// ## 职责
///
/// - 内存中持有当前会话（供拦截器/守卫同步读取 token）
/// - 与 SecureStorage 交互实现持久化
/// - 启动阶段恢复本地会话
///
/// ## 使用
///
/// ```dart
/// // 启动恢复
/// await authStore.init();
///
/// // 拦截器同步读 token
/// authStore.bearerToken;
/// ```
class AuthStore {
  AuthStore({String storageKey = 'auth_session'}) : _storageKey = storageKey;

  final String _storageKey;
  AuthSession? _current;

  // ---- 同步访问 ----

  AuthSession? get current => _current;
  bool get isAuthenticated => _current?.isValid == true;
  String? get token => _current?.token;
  String? get bearerToken => _current?.bearerToken;

  /// 仅更新内存会话，不写入持久化存储。
  ///
  /// 主要用于 Widget 测试或外部已完成持久化的高级场景。
  void setMemorySession(AuthSession? session) {
    _current = session?.isValid == true ? session : null;
  }

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

/// 全局实例（ProviderScope 前由 Application.run 初始化）。
final authStore = AuthStore();
