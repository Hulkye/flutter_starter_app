import 'package:flutter_starter_app/core/network/http/response/api_response.dart';
import 'package:flutter_starter_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter_starter_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_starter_app/features/auth/domain/exceptions/auth_exception.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/provider_container.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('sets auth session after successful login', () async {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
          authDataSourceProvider.overrideWith(
            (ref) => const _FakeAuthDataSource(
              response: ApiResponse<Map<String, dynamic>>(
                code: 0,
                data: {'token': 'token-from-api'},
              ),
            ),
          ),
        ],
      );
      final repository = container.read(authRepositoryProvider);

      await repository.login(' demo ', 'password');

      final session = container.read(authSessionProvider);
      expect(session?.token, 'token-from-api');
      expect(session?.payload['username'], ' demo ');
    });

    test(
      'throws typed rejected exception when business status fails',
      () async {
        final container = createTestContainer(
          overrides: [
            authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
            authDataSourceProvider.overrideWith(
              (ref) => const _FakeAuthDataSource(
                response: ApiResponse<Map<String, dynamic>>(
                  code: 40101,
                  message: 'Invalid credentials',
                ),
              ),
            ),
          ],
        );
        final repository = container.read(authRepositoryProvider);

        expect(
          () => repository.login('demo', 'bad-password'),
          throwsA(
            isA<AuthLoginRejectedException>()
                .having((error) => error.code, 'code', 40101)
                .having(
                  (error) => error.message,
                  'message',
                  'Invalid credentials',
                ),
          ),
        );
      },
    );

    test('throws typed invalid response exception when token is missing', () {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
          authDataSourceProvider.overrideWith(
            (ref) => const _FakeAuthDataSource(
              response: ApiResponse<Map<String, dynamic>>(
                code: 0,
                message: 'success',
                data: {},
              ),
            ),
          ),
        ],
      );
      final repository = container.read(authRepositoryProvider);

      expect(
        () => repository.login('demo', 'password'),
        throwsA(isA<AuthInvalidResponseException>()),
      );
    });
  });
}

final class _FakeAuthDataSource implements AuthDataSource {
  const _FakeAuthDataSource({required this.response});

  final ApiResponse<Map<String, dynamic>> response;

  @override
  Future<ApiResponse<Map<String, dynamic>>> login(
    String username,
    String password,
  ) async {
    return response;
  }
}

final class _TestAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSession? build() => null;

  @override
  Future<void> setSession(AuthSession session) async {
    state = session;
  }

  @override
  Future<void> clear() async {
    state = null;
  }
}
