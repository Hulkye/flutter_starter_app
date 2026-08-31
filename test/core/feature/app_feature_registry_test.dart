import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_feature.dart';
import 'package:flutter_starter_app/core/feature/app_feature_metadata.dart';
import 'package:flutter_starter_app/core/feature/app_feature_registry.dart';
import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

final _bindingProvider = Provider<String>((ref) => 'default');

void main() {
  group('AppFeatureRegistry', () {
    test('filters by environment and aggregates only enabled features', () {
      final registry = AppFeatureRegistry(
        environment: EnvTag.prod,
        candidates: <AppFeature>[
          _TestFeature(
            metadata: const AppFeatureMetadata(
              key: 'dev-only',
              enabledEnvironments: <EnvTag>{EnvTag.dev},
            ),
            routes: const <AppPageRoute>[_TestRoute('/dev')],
            tabs: const <AppTabEntry>[_TestTab('dev.tab', '/dev')],
            providerOverrides: <Override>[
              _bindingProvider.overrideWithValue('dev'),
            ],
          ),
          _TestFeature(
            metadata: const AppFeatureMetadata(key: 'prod'),
            routes: const <AppPageRoute>[
              _TestRoute('/prod'),
              _TestRoute('/prod/detail'),
            ],
            tabs: const <AppTabEntry>[_TestTab('prod.tab', '/prod')],
            providerOverrides: <Override>[
              _bindingProvider.overrideWithValue('prod'),
            ],
          ),
        ],
      );

      expect(registry.features.map((feature) => feature.key), <String>['prod']);
      expect(registry.tabs.map((tab) => tab.key), <String>['prod.tab']);
      expect(registry.routes.map((route) => route.path), <String>[
        '/prod/detail',
      ]);
      expect(registry.providerOverrides, hasLength(1));
    });

    test('sorts by priority and then key', () {
      final registry = AppFeatureRegistry(
        environment: EnvTag.dev,
        candidates: <AppFeature>[
          _feature(key: 'charlie', priority: 20, path: '/charlie'),
          _feature(key: 'bravo', priority: 10, path: '/bravo'),
          _feature(key: 'alpha', priority: 10, path: '/alpha'),
        ],
      );

      expect(registry.features.map((feature) => feature.key), <String>[
        'alpha',
        'bravo',
        'charlie',
      ]);
    });

    test('rejects duplicate feature keys', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _feature(key: 'duplicate', priority: 1, path: '/first'),
            _feature(key: 'duplicate', priority: 2, path: '/second'),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Feature key conflict "duplicate"'),
          ),
        ),
      );
    });

    test('rejects duplicate route paths with feature sources', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _feature(key: 'first', priority: 1, path: '/shared'),
            _feature(key: 'second', priority: 2, path: '/shared'),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(contains('/shared'), contains('first and second')),
          ),
        ),
      );
    });

    test('rejects duplicate tab keys with feature sources', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _feature(
              key: 'first',
              priority: 1,
              path: '/first',
              tabKey: 'shared.tab',
            ),
            _feature(
              key: 'second',
              priority: 2,
              path: '/second',
              tabKey: 'shared.tab',
            ),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(contains('shared.tab'), contains('first and second')),
          ),
        ),
      );
    });

    test('rejects a tab route not declared by its feature', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'invalid'),
              routes: const <AppPageRoute>[_TestRoute('/declared')],
              tabs: const <AppTabEntry>[_TestTab('invalid.tab', '/missing')],
            ),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('invalid.tab'),
              contains('/missing'),
              contains('invalid'),
            ),
          ),
        ),
      );
    });
  });
}

_TestFeature _feature({
  required String key,
  required int priority,
  required String path,
  String? tabKey,
}) {
  return _TestFeature(
    metadata: AppFeatureMetadata(key: key, priority: priority),
    routes: <AppPageRoute>[_TestRoute(path)],
    tabs: tabKey == null
        ? const <AppTabEntry>[]
        : <AppTabEntry>[_TestTab(tabKey, path)],
  );
}

final class _TestFeature extends AppFeature {
  const _TestFeature({
    required this.metadata,
    required this.routes,
    this.tabs = const <AppTabEntry>[],
    this.providerOverrides = const <Override>[],
  });

  @override
  final AppFeatureMetadata metadata;

  @override
  final List<AppPageRoute> routes;

  @override
  final List<AppTabEntry> tabs;

  @override
  final List<Override> providerOverrides;
}

final class _TestRoute extends AppPageRoute {
  const _TestRoute(this.path);

  @override
  final String path;

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const SizedBox.shrink();
  }
}

final class _TestTab extends AppTabEntry {
  const _TestTab(this.key, this.path);

  @override
  final String key;

  final String path;

  @override
  String label(BuildContext context) => key;

  @override
  String icon(BuildContext context) => '';

  @override
  String selectedIcon(BuildContext context) => '';

  @override
  AppPageRoute get route => _TestRoute(path);
}
