import 'package:flutter_starter_app/integrations/deep_link/application/deep_link_resolver.dart';
import 'package:flutter_starter_app/integrations/deep_link/domain/deep_link_models.dart';
import 'package:flutter_starter_app/core/config/deep_link_config.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/shared/webview/domain/web_page_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  const config = EnvConfig(
    deepLinkConfig: DeepLinkConfig(
      appScheme: 'starter',
      appLinkHost: 'links.example.com',
    ),
  );

  group('DeepLinkResolver', () {
    test(
      'resolves configured app scheme route and ignores unknown parameters',
      () {
        final resolver = DeepLinkResolver(
          config: config,
          routes: const [_DeepLinkTodoRoute()],
        );

        final result = resolver.resolve(
          Uri.parse('starter:///todo?filter=open&utm_source=newsletter'),
        );

        expect(result, isA<DeepLinkAccepted>());
        final command = (result as DeepLinkAccepted).command;
        expect(command.location, '/todo?filter=open&utm_source=newsletter');
        expect(command.requiresAuthentication, isFalse);
      },
    );

    test('rejects routes that did not explicitly enable deep links', () {
      final result = const DeepLinkResolver(
        config: EnvConfig(
          deepLinkConfig: DeepLinkConfig(
            appScheme: 'starter',
            appLinkHost: 'links.example.com',
          ),
        ),
        routes: [_DeepLinkDisabledRoute()],
      ).resolve(Uri.parse('starter:///profile'));

      expect(result, isA<DeepLinkInvalid>());
      expect(
        (result as DeepLinkInvalid).reason,
        DeepLinkInvalidReason.unknownPath,
      );
    });

    test('ignores unknown business query parameters', () {
      final result = DeepLinkResolver(
        config: config,
        routes: const [_DeepLinkTodoRoute()],
      ).resolve(Uri.parse('starter:///todo?filter=open&unknown=value'));

      expect(result, isA<DeepLinkAccepted>());
      expect(
        (result as DeepLinkAccepted).command.location,
        '/todo?filter=open&unknown=value',
      );
    });

    test(
      'opens a web path from an app scheme and normalizes missing scheme',
      () {
        final result = const DeepLinkResolver(
          config: EnvConfig(
            deepLinkConfig: DeepLinkConfig(
              appScheme: 'starter',
              appLinkHost: 'links.example.com',
            ),
          ),
        ).resolve(Uri.parse('starter:///web?url=www.example.com/docs'));

        expect(result, isA<DeepLinkAccepted>());
        final command = (result as DeepLinkAccepted).command;
        expect(
          command.location,
          '/web?url=https%3A%2F%2Fwww.example.com%2Fdocs',
        );
        expect(command.requiresAuthentication, isFalse);
        expect(
          (command.extra as WebPageConfig).url,
          'https://www.example.com/docs',
        );
      },
    );

    test('opens a web path from an app link without host revalidation', () {
      const resolver = DeepLinkResolver(config: EnvConfig());

      final result = resolver.resolve(
        Uri.parse(
          'https://links.example.com/web?url=https%3A%2F%2Fwww.example.com',
        ),
      );

      expect(result, isA<DeepLinkAccepted>());
      expect(
        ((result as DeepLinkAccepted).command.extra as WebPageConfig).url,
        'https://www.example.com',
      );
    });

    test('rejects unsafe URL parts and unknown paths', () {
      const resolver = DeepLinkResolver(config: EnvConfig());

      final unsafe = resolver.resolve(
        Uri.parse('https://example.com@evil.test/path'),
      );
      expect(unsafe, isA<DeepLinkInvalid>());
      expect(
        (unsafe as DeepLinkInvalid).reason,
        DeepLinkInvalidReason.unsafeUri,
      );

      final unknown = resolver.resolve(Uri.parse('https://evil.test/path'));
      expect(unknown, isA<DeepLinkInvalid>());
      expect(
        (unknown as DeepLinkInvalid).reason,
        DeepLinkInvalidReason.unknownPath,
      );
    });
  });
}

final class _DeepLinkTodoRoute extends AppPageRoute {
  const _DeepLinkTodoRoute();

  @override
  String get path => '/todo';

  @override
  bool get public => true;

  @override
  bool get deepLinkEnabled => true;

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const SizedBox.shrink();
  }
}

final class _DeepLinkDisabledRoute extends AppPageRoute {
  const _DeepLinkDisabledRoute();

  @override
  String get path => '/profile';

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const SizedBox.shrink();
  }
}
