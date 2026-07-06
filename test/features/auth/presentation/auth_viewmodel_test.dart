import 'package:flutter_starter_app/core/l10n/app_locale.dart';
import 'package:flutter_starter_app/core/l10n/l10n_provider.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/features/auth/domain/exceptions/auth_exception.dart';
import 'package:flutter_starter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/provider_container.dart';

void main() {
  group('AuthViewModel', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await prefsStorage.init();
    });

    test(
      'maps rejected auth exception to localized fallback message',
      () async {
        final container = createTestContainer(
          overrides: [
            appLocaleProvider.overrideWith(
              () => _FixedLocaleNotifier(AppLocale.en),
            ),
            authRepositoryProvider.overrideWith(
              (ref) => const _ThrowingAuthRepository(
                AuthLoginRejectedException(
                  code: 40101,
                  message: 'Invalid credentials',
                ),
              ),
            ),
          ],
        );
        final vm = container.read(authViewModelProvider.notifier);

        await vm.login('demo', 'bad-password');

        final state = container.read(authViewModelProvider);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, 'Login failed');
      },
    );

    test('maps invalid auth response to localized fallback message', () async {
      final container = createTestContainer(
        overrides: [
          appLocaleProvider.overrideWith(
            () => _FixedLocaleNotifier(AppLocale.zh),
          ),
          authRepositoryProvider.overrideWith(
            (ref) => const _ThrowingAuthRepository(
              AuthInvalidResponseException(code: 0, message: 'success'),
            ),
          ),
        ],
      );
      final vm = container.read(authViewModelProvider.notifier);

      await vm.login('demo', 'password');

      final state = container.read(authViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '登录失败');
    });

    test('clears loading and error after successful login', () async {
      final container = createTestContainer(
        overrides: [
          authRepositoryProvider.overrideWith(
            (ref) => const _SuccessfulAuthRepository(),
          ),
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
        ],
      );
      final vm = container.read(authViewModelProvider.notifier);

      await vm.login('demo', 'password');

      final state = container.read(authViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(container.read(authSessionProvider)?.token, 'test-token');
    });
  });
}

final class _ThrowingAuthRepository implements AuthRepository {
  const _ThrowingAuthRepository(this.error);

  final Object error;

  @override
  Future<AuthSession> login(String username, String password) {
    throw error;
  }
}

final class _SuccessfulAuthRepository implements AuthRepository {
  const _SuccessfulAuthRepository();

  @override
  Future<AuthSession> login(String username, String password) async {
    return const AuthSession(token: 'test-token');
  }
}

final class _FixedLocaleNotifier extends AppLocaleNotifier {
  _FixedLocaleNotifier(this._locale);

  final AppLocale _locale;

  @override
  AppLocale build() => _locale;
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
