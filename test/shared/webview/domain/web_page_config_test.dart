import 'package:flutter_starter_app/shared/webview/webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebPageConfig', () {
    test('uses extra config before query parameters', () {
      const extra = WebPageConfig(
        url: 'https://example.com/extra',
        title: 'Extra',
        allowedHosts: ['example.com'],
      );

      final config = WebPageConfig.fromRouteState(
        queryParameters: const {
          'url': 'https://example.org/query',
          'title': 'Query',
        },
        extra: extra,
      );

      expect(config, same(extra));
      expect(config.url, 'https://example.com/extra');
      expect(config.title, 'Extra');
    });

    test('builds config from query parameters without extra', () {
      final config = WebPageConfig.fromRouteState(
        queryParameters: const {
          'url': 'https://example.com/path',
          'title': 'Docs',
        },
      );

      expect(config.url, 'https://example.com/path');
      expect(config.title, 'Docs');
      expect(config.canLoad, isTrue);
    });

    test('validates empty, invalid, and unsupported scheme urls', () {
      expect(
        const WebPageConfig(url: '').validate(),
        WebPageValidationResult.invalidUrl,
      );
      expect(
        const WebPageConfig(url: 'not a url').validate(),
        WebPageValidationResult.invalidUrl,
      );
      expect(
        const WebPageConfig(url: 'tel:123456').validate(),
        WebPageValidationResult.invalidUrl,
      );
    });

    test('allows http and https urls when hosts are unrestricted', () {
      expect(const WebPageConfig(url: 'https://example.com').canLoad, isTrue);
      expect(const WebPageConfig(url: 'http://example.com').canLoad, isTrue);
    });

    test('checks allowed hosts when configured', () {
      expect(
        const WebPageConfig(
          url: 'https://example.com/docs',
          allowedHosts: ['example.com'],
        ).validate(),
        WebPageValidationResult.ok,
      );
      expect(
        const WebPageConfig(
          url: 'https://blocked.example.com/docs',
          allowedHosts: ['example.com'],
        ).validate(),
        WebPageValidationResult.blockedHost,
      );
    });
  });
}
