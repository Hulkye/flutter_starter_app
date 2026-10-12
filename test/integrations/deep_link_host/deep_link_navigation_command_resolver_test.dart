import 'package:app_deep_link/app_deep_link.dart';
import 'package:flutter_starter_app/core/navigation/app_navigation_command.dart';
import 'package:flutter_starter_app/integrations/deep_link_host/deep_link_navigation_command_resolver.dart';
import 'package:flutter_starter_app/shared/webview/domain/web_page_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = DeepLinkNavigationCommandResolver();

  test('resolves ordinary deep links into typed navigation commands', () {
    final command = resolver.resolve(
      const DeepLinkMatch(
        route: DeepLinkRoute(
          key: 'todo',
          path: '/todo',
          requiresAuthentication: false,
        ),
        source: DeepLinkSourceKind.appScheme,
        queryParameters: <String, String>{'filter': 'open'},
      ),
    );

    expect(command?.source, AppNavigationSource.deepLink);
    expect(command?.path, '/todo');
    expect(command?.requiresAuthentication, isFalse);
    expect(command?.target.location, '/todo?filter=open');
  });

  test('normalizes web links and keeps a typed WebPageConfig extra', () {
    final command = resolver.resolve(
      const DeepLinkMatch(
        route: DeepLinkRoute(
          key: '/web',
          path: '/web',
          requiresAuthentication: false,
        ),
        source: DeepLinkSourceKind.appLink,
        queryParameters: <String, String>{'url': 'example.com/docs'},
      ),
    );

    expect(
      command?.target.location,
      '/web?url=https%3A%2F%2Fexample.com%2Fdocs',
    );
    expect(command?.extra, isA<WebPageConfig>());
  });

  test('rejects web links with an unsupported URL scheme', () {
    final command = resolver.resolve(
      const DeepLinkMatch(
        route: DeepLinkRoute(
          key: '/web',
          path: '/web',
          requiresAuthentication: false,
        ),
        source: DeepLinkSourceKind.appScheme,
        queryParameters: <String, String>{'url': 'ftp://example.com'},
      ),
    );

    expect(command, isNull);
  });
}
