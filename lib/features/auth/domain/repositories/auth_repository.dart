import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/auth/auth_session.dart';

/// 认证数据仓库接口（领域层）。
abstract class AuthRepository {
  /// 登录并返回可写入 App 会话源的认证会话。
  Future<AuthSession> login(String username, String password);
}

/// AuthRepository 抽象 Provider。
///
/// presentation 只依赖该 Provider。默认 data 实现由 App 组合层通过
/// [authRepositoryBindingProvider] 注入；测试或环境可以直接 override 本 Provider。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryBindingProvider);
});

/// AuthRepository 默认实现装配点。
///
/// 由 App 组合层注入 data 实现，避免 presentation 直接依赖 data。
final authRepositoryBindingProvider = Provider<AuthRepository>((ref) {
  throw StateError(
    'authRepositoryBindingProvider must be overridden by app composition.',
  );
});
