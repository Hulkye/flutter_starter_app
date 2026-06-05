import '../../core/feature/app_feature.dart';
import '../../core/router/app_route_define.dart';
import 'presentation/home_routes.dart';

export 'presentation/home_routes.dart';

final class HomeFeature extends AppFeature {
  const HomeFeature();

  @override
  String get name => 'home';

  @override
  List<AppRouteDefine> get routes => const [HomeRoute()];
}
