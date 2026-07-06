import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/services/auth/auth_provider.dart';
import '../../../../shared/services/auth/auth_session.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// [AuthRepository] 的实现（数据层）。
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._ref, this._dataSource);

  final Ref _ref;
  final AuthDataSource _dataSource;

  @override
  Future<void> login(String username, String password) async {
    final response = await _dataSource.login(username, password);
    if (!response.isSuccess) {
      throw AuthLoginRejectedException(
        code: response.code,
        message: response.message,
      );
    }
    final data = response.data;
    final token = data?['token']?.toString().trim() ?? '';
    if (token.isEmpty) {
      throw AuthInvalidResponseException(
        code: response.code,
        message: response.message,
      );
    }
    await _ref
        .read(authSessionProvider.notifier)
        .setSession(
          AuthSession(
            token: token,
            payload: <String, dynamic>{'username': username},
          ),
        );
  }

  @override
  Future<void> logout() async {
    await _ref.read(authSessionProvider.notifier).clear();
  }
}

/// AuthRepository Provider。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref, ref.watch(authDataSourceProvider));
});
