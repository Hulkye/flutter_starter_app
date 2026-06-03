import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig', () {
    test('normalizes api base url with slashes', () {
      const config = EnvConfig(
        baseUrl: 'https://api.example.com/',
        apiPathPrefix: 'v1',
      );

      expect(config.apiBaseUrl, 'https://api.example.com/v1');
    });

    test('uses prefix when base url is empty', () {
      const config = EnvConfig(apiPathPrefix: '/mock-api');

      expect(config.apiBaseUrl, '/mock-api');
    });

    test('uses base url when prefix is root', () {
      const config = EnvConfig(
        baseUrl: 'https://api.example.com/',
        apiPathPrefix: '/',
      );

      expect(config.apiBaseUrl, 'https://api.example.com');
    });

    test('disables http log by default in production', () {
      const dev = EnvConfig(envTag: EnvTag.dev);
      const prod = EnvConfig(envTag: EnvTag.prod);

      expect(dev.httpLogEnable, isTrue);
      expect(prod.httpLogEnable, isFalse);
    });
  });
}
