import '../../../../shared/services/auth/auth_session.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// [AuthRepository] 的实现（数据层）。
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<AuthSession> login(String username, String password) async {
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
    final refreshToken = data?['refreshToken']?.toString().trim();
    return AuthSession(
      token: token,
      refreshToken: refreshToken?.isEmpty == true ? null : refreshToken,
      payload: <String, dynamic>{'username': username},
    );
  }
}
