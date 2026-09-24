import 'dart:async';

import 'package:app_deep_link/app_deep_link.dart';
import 'package:test/test.dart';

void main() {
  const config = DeepLinkConfig(
    appScheme: 'starter',
    appLinkHost: 'links.example.com',
  );
  const routes = <DeepLinkRoute>[
    DeepLinkRoute(key: 'todo', path: '/todo', requiresAuthentication: false),
  ];

  group('DeepLinkEngine', () {
    test('resolves a configured app scheme route', () {
      final result = DeepLinkEngine(
        config: config,
        routes: routes,
      ).resolve(Uri.parse('starter:///todo?filter=open'));

      expect(result, isA<DeepLinkAccepted>());
      final match = (result as DeepLinkAccepted).match;
      expect(match.route.key, 'todo');
      expect(match.queryParameters, {'filter': 'open'});
      expect(match.source, DeepLinkSourceKind.appScheme);
    });

    test('accepts only the configured app link host', () {
      final engine = DeepLinkEngine(config: config, routes: routes);

      expect(
        engine.resolve(Uri.parse('https://links.example.com/todo')),
        isA<DeepLinkAccepted>(),
      );
      final result = engine.resolve(Uri.parse('https://evil.example.com/todo'));
      expect(result, isA<DeepLinkInvalid>());
      expect(
        (result as DeepLinkInvalid).reason,
        DeepLinkInvalidReason.blockedHost,
      );
    });

    test('rejects routes that are not registered', () {
      final result = DeepLinkEngine(
        config: config,
        routes: routes,
      ).resolve(Uri.parse('starter:///profile'));

      expect(result, isA<DeepLinkInvalid>());
      expect(
        (result as DeepLinkInvalid).reason,
        DeepLinkInvalidReason.unknownPath,
      );
    });

    test('rejects unsafe URI parts', () {
      final result = DeepLinkEngine(config: config, routes: routes).resolve(
        Uri.parse('https://user:password@links.example.com/todo#fragment'),
      );

      expect(result, isA<DeepLinkInvalid>());
      expect(
        (result as DeepLinkInvalid).reason,
        DeepLinkInvalidReason.unsafeUri,
      );
    });

    test('handles the initial URI before stream events', () async {
      final source = _FakeSource(Uri.parse('starter:///todo'));
      final engine = DeepLinkEngine(
        config: config,
        routes: routes,
        source: source,
      );
      final resolutions = <DeepLinkResolution>[];

      await engine.start(resolutions.add);

      expect(resolutions, hasLength(1));
      expect(resolutions.single, isA<DeepLinkAccepted>());
      await engine.dispose();
    });
  });
}

final class _FakeSource implements DeepLinkUriSource {
  _FakeSource(this.initialUri);

  final Uri? initialUri;
  final _controller = StreamController<Uri>();

  @override
  Future<Uri?> getInitialUri() async => initialUri;

  @override
  Stream<Uri> get uriStream => _controller.stream;

  @override
  Future<void> dispose() => _controller.close();
}
