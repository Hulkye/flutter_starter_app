import 'package:flutter_starter_app/shared/services/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/provider_container.dart';

void main() {
  group('AuthSessionController', () {
    test('saves session to single session source', () async {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
        ],
      );

      await container
          .read(authSessionControllerProvider)
          .saveSession(
            const AuthSession(
              token: 'test-token',
              payload: <String, dynamic>{'username': 'demo'},
            ),
          );

      expect(container.read(authSessionProvider)?.token, 'test-token');
      expect(container.read(authSessionProvider)?.payload['username'], 'demo');
    });

    test('clears session source', () async {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
        ],
      );

      await container
          .read(authSessionControllerProvider)
          .saveSession(const AuthSession(token: 'test-token'));
      await container.read(authSessionControllerProvider).clearSession();

      expect(container.read(authSessionProvider), isNull);
    });

    test('updates session payload', () async {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
        ],
      );

      await container
          .read(authSessionControllerProvider)
          .saveSession(
            const AuthSession(
              token: 'test-token',
              payload: <String, dynamic>{'username': 'demo'},
            ),
          );
      await container.read(authSessionControllerProvider).updatePayload(
        <String, dynamic>{'role': 'admin'},
      );

      expect(container.read(authSessionProvider)?.payload['username'], 'demo');
      expect(container.read(authSessionProvider)?.payload['role'], 'admin');
    });
  });
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
