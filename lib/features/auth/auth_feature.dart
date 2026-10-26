import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/router/export.dart';

import '../../core/feature/app_feature.dart';
import '../../core/feature/app_feature_metadata.dart';
import '../../core/feature/app_route_policy.dart';
import 'data/datasources/auth_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/auth_routes.dart';

final class AuthFeature extends AppFeature {
  const AuthFeature();

  @override
  AppFeatureMetadata get metadata =>
      const AppFeatureMetadata(key: 'auth', priority: 100);

  @override
  List<AppPageRoute<dynamic>> get routes => const [LoginRoute()];

  @override
  List<AppRoutePolicy> get routePolicies => const [
    AppRoutePolicy(
      routeKey: LoginRoute.routeKey,
      requiresAuthentication: false,
    ),
  ];

  @override
  List<Override> get providerOverrides {
    return <Override>[
      authRepositoryBindingProvider.overrideWith(
        (ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
      ),
    ];
  }
}
