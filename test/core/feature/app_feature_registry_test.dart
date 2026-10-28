import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_feature.dart';
import 'package:flutter_starter_app/core/feature/app_external_route.dart';
import 'package:flutter_starter_app/core/feature/app_feature_metadata.dart';
import 'package:flutter_starter_app/core/feature/app_feature_registry.dart';
import 'package:flutter_starter_app/core/feature/app_route_policy.dart';
import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';

final _bindingProvider = Provider<String>((ref) => 'default');
const _testLocalizationDelegate = _TestLocalizationDelegate();

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
            externalRoutes: const <AppExternalRoute>[
              AppExternalRoute(key: 'dev', route: _TestRoute('/dev')),
            ],
            providerOverrides: <Override>[
              _bindingProvider.overrideWithValue('dev'),
            ],
            lightThemeExtensions: const <Object>[_TestThemeExtension('dev')],
          ),
          _TestFeature(
            metadata: const AppFeatureMetadata(key: 'prod'),
            routes: const <AppPageRoute>[
              _TestRoute('/prod'),
              _TestRoute('/prod/detail'),
            ],
            tabs: const <AppTabEntry>[_TestTab('prod.tab', '/prod')],
            externalRoutes: const <AppExternalRoute>[
              AppExternalRoute(key: 'prod', route: _TestRoute('/prod')),
            ],
            guards: const <AppRouteGuard>[_TestGuard()],
            providerOverrides: <Override>[
              _bindingProvider.overrideWithValue('prod'),
            ],
            lightThemeExtensions: const <Object>[_TestThemeExtension('prod')],
            localizationDelegates: const <LocalizationsDelegate<dynamic>>[
              _testLocalizationDelegate,
            ],
          ),
        ],
      );

      expect(registry.features.map((feature) => feature.key), <String>['prod']);
      expect(registry.tabs.map((tab) => tab.key), <String>['prod.tab']);
      expect(registry.routes.map((route) => route.path), <String>[
        '/prod/detail',
      ]);
      expect(registry.externalRoutes.map((route) => route.key), <String>[
        'prod',
      ]);
      expect(registry.providerOverrides, hasLength(1));
      expect(registry.guards, hasLength(1));
      expect(registry.localizationDelegates, hasLength(1));
      expect(
        registry.localizationDelegates.single,
        same(_testLocalizationDelegate),
      );
      expect(registry.lightThemeExtensions, hasLength(1));
      expect(registry.lightThemeExtensions.single.featureKey, 'prod');
      expect(
        registry.lightThemeExtensions.single.value,
        const _TestThemeExtension('prod'),
      );
      expect(registry.routesByKey['/prod'], isA<_TestRoute>());
      expect(registry.routesByPath['/prod/detail'], isA<_TestRoute>());
      expect(registry.routesByPath, isNot(contains('/dev')));
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

    test('rejects duplicate localization delegate types', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'first'),
              routes: const <AppPageRoute>[_TestRoute('/first')],
              localizationDelegates: const <LocalizationsDelegate<dynamic>>[
                _TestLocalizationDelegate(),
              ],
            ),
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'second'),
              routes: const <AppPageRoute>[_TestRoute('/second')],
              localizationDelegates: const <LocalizationsDelegate<dynamic>>[
                _TestLocalizationDelegate(),
              ],
            ),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('_TestLocalizationDelegate'),
              contains('first and second'),
            ),
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

    test('rejects duplicate external route keys with feature sources', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'first'),
              routes: const <AppPageRoute>[_TestRoute('/first')],
              externalRoutes: const <AppExternalRoute>[
                AppExternalRoute(key: 'shared', route: _TestRoute('/first')),
              ],
            ),
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'second'),
              routes: const <AppPageRoute>[_TestRoute('/second')],
              externalRoutes: const <AppExternalRoute>[
                AppExternalRoute(key: 'shared', route: _TestRoute('/second')),
              ],
            ),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(contains('shared'), contains('first and second')),
          ),
        ),
      );
    });

    test('rejects an external route not declared by its feature', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'invalid'),
              routes: const <AppPageRoute>[_TestRoute('/declared')],
              externalRoutes: const <AppExternalRoute>[
                AppExternalRoute(key: 'invalid', route: _TestRoute('/missing')),
              ],
            ),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(contains('invalid'), contains('/missing')),
          ),
        ),
      );
    });

    test('rejects a route policy not declared by its feature', () {
      expect(
        () => AppFeatureRegistry(
          environment: EnvTag.dev,
          candidates: <AppFeature>[
            _TestFeature(
              metadata: const AppFeatureMetadata(key: 'invalid'),
              routes: const <AppPageRoute>[_TestRoute('/declared')],
              routePolicies: const <AppRoutePolicy>[
                AppRoutePolicy(routeKey: 'missing'),
              ],
            ),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(contains('missing'), contains('invalid')),
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
    this.externalRoutes = const <AppExternalRoute>[],
    this.guards = const <AppRouteGuard>[],
    this.routePolicies = const <AppRoutePolicy>[],
    this.providerOverrides = const <Override>[],
    this.lightThemeExtensions = const <Object>[],
    this.localizationDelegates = const <LocalizationsDelegate<dynamic>>[],
  });

  @override
  final AppFeatureMetadata metadata;

  @override
  final List<AppPageRoute> routes;

  @override
  final List<AppTabEntry> tabs;

  @override
  final List<AppExternalRoute> externalRoutes;

  @override
  final List<AppRouteGuard> guards;

  @override
  final List<AppRoutePolicy> routePolicies;

  @override
  final List<Override> providerOverrides;

  @override
  final List<Object> lightThemeExtensions;

  @override
  final List<LocalizationsDelegate<dynamic>> localizationDelegates;
}

final class _TestLocalizationDelegate extends LocalizationsDelegate<dynamic> {
  const _TestLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<dynamic> load(Locale locale) async => Object();

  @override
  bool shouldReload(covariant _TestLocalizationDelegate old) => false;
}

final class _TestThemeExtension extends ThemeExtension<_TestThemeExtension> {
  const _TestThemeExtension(this.value);

  final String value;

  @override
  _TestThemeExtension copyWith({String? value}) {
    return _TestThemeExtension(value ?? this.value);
  }

  @override
  _TestThemeExtension lerp(covariant _TestThemeExtension? other, double t) {
    return other ?? this;
  }
}

final class _TestRoute extends AppPageRoute<void> {
  const _TestRoute(this.path);

  @override
  final String path;

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const SizedBox.shrink();
  }
}

final class _TestGuard implements AppRouteGuard {
  const _TestGuard();

  @override
  RouteAccessDecision evaluate(AppRouteRequest request) => const AllowRoute();
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

  @override
  AppRouteTarget get initialTarget => _TestTarget(path);
}

final class _TestTarget extends AppRouteTargetBase {
  const _TestTarget(this.location);

  @override
  final String location;
}
