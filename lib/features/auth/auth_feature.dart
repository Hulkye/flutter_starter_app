import '../../core/feature/app_feature.dart';
import '../../core/router/app_route_define.dart';
import 'presentation/auth_routes.dart';

export 'presentation/auth_routes.dart';

final class AuthFeature extends AppFeature {
  const AuthFeature();

  @override
  String get name => 'auth';

  @override
  List<AppRouteDefine> get routes => const [LoginRoute()];
}
