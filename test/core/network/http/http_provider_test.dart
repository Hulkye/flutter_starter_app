import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_starter_app/core/network/http/http_provider.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_provider.dart';
import 'package:flutter_starter_app/shared/services/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/provider_container.dart';

void main() {
  group('httpConfigProvider auth integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'en'});
      await prefsStorage.init();
      appConfig = const EnvConfig(envTag: EnvTag.sit);
    });

    test('reads bearer token from authSessionProvider for headers', () async {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _TestAuthSessionNotifier(
              const AuthSession(token: 'provider-token'),
            ),
          ),
        ],
      );

      final config = container.read(httpConfigProvider);
      final headers = await config.authConfig!.headerMapProvider!();

      expect(headers?['X-App-Channel'], 'flutter_starter_app');
      expect(headers?['X-App-Env'], 'sit');
      expect(headers?['Authorization'], 'Bearer provider-token');
    });

    test('clears authSessionProvider when auth fails', () async {
      final container = createTestContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _TestAuthSessionNotifier(
              const AuthSession(token: 'provider-token'),
            ),
          ),
        ],
      );

      final config = container.read(httpConfigProvider);
      expect(container.read(authSessionProvider)?.token, 'provider-token');

      await config.authConfig!.onAuthFailed!();

      expect(container.read(authSessionProvider), isNull);
    });
  });
}

final class _TestAuthSessionNotifier extends AuthSessionNotifier {
  _TestAuthSessionNotifier(this._initialSession);

  final AuthSession? _initialSession;

  @override
  AuthSession? build() => _initialSession;

  @override
  Future<void> clear() async {
    state = null;
  }
}
