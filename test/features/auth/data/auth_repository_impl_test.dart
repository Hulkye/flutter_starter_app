import 'package:flutter_starter_app/core/network/http/response/api_response.dart';
import 'package:flutter_starter_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:flutter_starter_app/features/auth/auth_feature.dart';
import 'package:flutter_starter_app/features/auth/domain/exceptions/auth_exception.dart';
import 'package:flutter_starter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/provider_container.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('returns auth session without writing global session', () async {
      final container = createTestContainer(
        overrides: [
          ...const AuthFeature().providerOverrides,
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

      final session = await repository.login(' demo ', 'password');

      expect(session.token, 'token-from-api');
      expect(session.payload['username'], ' demo ');
      expect(container.read(authSessionProvider), isNull);
    });

    test(
      'throws typed rejected exception when business status fails',
      () async {
        final container = createTestContainer(
          overrides: [
            ...const AuthFeature().providerOverrides,
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
          ...const AuthFeature().providerOverrides,
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
