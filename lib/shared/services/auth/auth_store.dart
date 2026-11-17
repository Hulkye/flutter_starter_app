import '../../../core/storage/storage_provider.dart';
import 'auth_session.dart';

/// 认证会话存储。
///
/// ## 职责
///
/// - 持久化当前会话，并在启动阶段恢复到内存
/// - 作为 authSessionProvider 的存储后端
/// - 与 SecureStorage 交互实现持久化
///
/// App 内判断登录态、注入 token、处理登出时，应统一通过响应式
/// `authSessionProvider` 或 `AuthSessionController`，不要把本类作为业务侧登录态入口。
///
/// ## 使用
///
/// ```dart
/// // 启动恢复
/// await authStore.init();
///
/// // 业务读写
/// ref.read(authSessionControllerProvider).saveSession(session);
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

  /// 持久化成功后更新内存会话；失败时保留原会话并向调用方抛出异常。
  Future<void> setSession(AuthSession session) async {
    await secureStorage.setString(_storageKey, session.toJsonString());
    _current = session;
  }

  /// 持久化删除成功后清除内存会话；失败时保留原会话并向调用方抛出异常。
  Future<void> clear() async {
    await secureStorage.remove(_storageKey);
    _current = null;
  }
}

/// 全局实例（ProviderScope 前由 Application.run 初始化）。
final authStore = AuthStore();
