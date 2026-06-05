import '../../core/feature/app_feature.dart';
import '../../core/router/app_route_define.dart';
import 'presentation/profile_routes.dart';

export 'presentation/profile_routes.dart';

final class ProfileFeature extends AppFeature {
  const ProfileFeature();

  @override
  String get name => 'profile';

  @override
  List<AppRouteDefine> get routes => const [ProfileRoute()];
}
