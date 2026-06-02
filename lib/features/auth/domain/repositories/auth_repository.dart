/// 认证数据仓库接口（领域层）。
abstract class AuthRepository {
  /// 登录。
  Future<void> login(String username, String password);

  /// 登出。
  Future<void> logout();
}
