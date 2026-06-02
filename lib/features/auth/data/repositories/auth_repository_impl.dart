import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http/response/api_response.dart';
import '../../../../shared/services/auth/auth_manager.dart';
import '../../../../shared/services/auth/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// [AuthRepository] 的实现（数据层）。
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  Future<void> login(
    String username,
    String password, {
    required String fallbackErrorMessage,
  }) async {
    final response = await _dataSource.login(username, password);
    if (!response.isSuccess) {
      throw ApiException(
        code: response.code,
        message: response.message ?? fallbackErrorMessage,
      );
    }
    final data = response.data;
    await authManager.setSession(
      AuthSession(
        token: data?['token']?.toString() ?? '',
        payload: <String, dynamic>{'username': username},
      ),
    );
  }

  @override
  Future<void> logout() async {
    await authManager.clear();
  }
}

/// AuthRepository Provider。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});
