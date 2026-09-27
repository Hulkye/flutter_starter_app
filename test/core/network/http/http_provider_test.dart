import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/network/http/http_provider.dart';
import 'package:flutter_starter_app/core/network/http/http_auth_session.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
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
          httpAuthSessionAccessProvider.overrideWithValue(
            _TestHttpAuthSessionAccess('Bearer provider-token'),
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
          httpAuthSessionAccessProvider.overrideWithValue(
            _TestHttpAuthSessionAccess('Bearer provider-token'),
          ),
        ],
      );

      final config = container.read(httpConfigProvider);
      expect(
        container.read(httpAuthSessionAccessProvider).authorization,
        'Bearer provider-token',
      );

      await config.authConfig!.onAuthFailed!();

      expect(
        container.read(httpAuthSessionAccessProvider).authorization,
        isNull,
      );
    });
  });
}

final class _TestHttpAuthSessionAccess implements HttpAuthSessionAccess {
  _TestHttpAuthSessionAccess(this.authorization);

  @override
  String? authorization;

  @override
  Future<void> clearSession() async {
    authorization = null;
  }
}
