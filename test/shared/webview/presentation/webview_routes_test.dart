import 'package:flutter_starter_app/shared/webview/webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebPageRoute', () {
    test('encodes url and title into public web location', () {
      final uri = Uri.parse(
        WebPageTarget(
          WebPageConfig(
            url: 'https://example.com/docs?a=1&b=2',
            title: 'Docs & Help',
          ),
        ).location,
      );

      expect(uri.path, WebPageRoute.pathValue);
      expect(uri.queryParameters['url'], 'https://example.com/docs?a=1&b=2');
      expect(uri.queryParameters['title'], 'Docs & Help');
    });

    test('omits query when quick parameters are empty', () {
      expect(
        const WebPageTarget(WebPageConfig(url: '')).location,
        WebPageRoute.pathValue,
      );
    });
  });

  group('AuthWebPageRoute', () {
    test('encodes url and title into auth web location', () {
      final uri = Uri.parse(
        AuthWebPageTarget(
          WebPageConfig(url: 'https://example.com/private', title: 'Private'),
        ).location,
      );

      expect(uri.path, AuthWebPageRoute.pathValue);
      expect(uri.queryParameters['url'], 'https://example.com/private');
      expect(uri.queryParameters['title'], 'Private');
    });
  });
}
