import '../../core/feature/app_feature.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'presentation/profile_routes.dart';

export 'presentation/profile_routes.dart';

final class ProfileFeature extends AppFeature {
  const ProfileFeature();

  @override
  String get name => 'profile';

  @override
  List<AppPageRoute> get routes => const [ProfileRoute()];
}
