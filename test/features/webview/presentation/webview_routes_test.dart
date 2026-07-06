import 'package:flutter_starter_app/features/exports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebPageRoute', () {
    test('encodes url and title into public web location', () {
      const route = WebPageRoute(
        url: 'https://example.com/docs?a=1&b=2',
        title: 'Docs & Help',
      );

      final uri = Uri.parse(route.location);

      expect(uri.path, WebPageRoute.pathValue);
      expect(uri.queryParameters['url'], 'https://example.com/docs?a=1&b=2');
      expect(uri.queryParameters['title'], 'Docs & Help');
    });

    test('omits query when quick parameters are empty', () {
      expect(const WebPageRoute().location, WebPageRoute.pathValue);
    });
  });

  group('AuthWebPageRoute', () {
    test('encodes url and title into auth web location', () {
      const route = AuthWebPageRoute(
        url: 'https://example.com/private',
        title: 'Private',
      );

      final uri = Uri.parse(route.location);

      expect(uri.path, AuthWebPageRoute.pathValue);
      expect(uri.queryParameters['url'], 'https://example.com/private');
      expect(uri.queryParameters['title'], 'Private');
    });
  });
}
