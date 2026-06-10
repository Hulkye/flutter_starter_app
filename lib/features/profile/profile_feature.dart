import 'package:flutter/widgets.dart';

import '../../core/feature/app_feature.dart';
import '../../core/feature/app_tab_entry.dart';
import '../../core/l10n/l10n.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import '../../core/theme/theme.dart';
import 'presentation/profile_routes.dart';

export 'presentation/profile_routes.dart';

final class ProfileFeature extends AppFeature {
  const ProfileFeature();

  @override
  String get name => 'profile';

  @override
  List<AppPageRoute> get routes => const [ProfileRoute()];

  @override
  List<AppTabEntry> get tabs => const [_ProfileTabEntry()];
}

final class _ProfileTabEntry extends AppTabEntry {
  const _ProfileTabEntry();

  @override
  String get key => 'profile.root';

  @override
  String label(BuildContext context) => context.i18n.profileTitle;

  @override
  String icon(BuildContext context) => context.appAsset.tabProfile;

  @override
  String selectedIcon(BuildContext context) =>
      context.appAsset.tabProfileSelected;

  @override
  AppPageRoute get route => const ProfileRoute();
}
