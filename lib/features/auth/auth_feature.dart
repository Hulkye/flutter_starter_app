import 'package:flutter_starter_app/core/router/definitions/app_page_route.dart';

import '../../core/feature/app_feature.dart';
import 'presentation/auth_routes.dart';

export 'presentation/auth_routes.dart';

final class AuthFeature extends AppFeature {
  const AuthFeature();

  @override
  String get name => 'auth';

  @override
  List<AppPageRoute> get routes => const [LoginRoute()];
}
