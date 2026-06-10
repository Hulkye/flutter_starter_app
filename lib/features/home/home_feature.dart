import 'package:flutter/widgets.dart';
import 'package:flutter_starter_app/core/feature/app_tab_entry.dart';
import 'package:flutter_starter_app/core/l10n/l10n.dart';
import 'package:flutter_starter_app/core/router/router.dart';
import 'package:flutter_starter_app/core/theme/theme.dart';

import '../../core/feature/app_feature.dart';
import 'presentation/home_routes.dart';

export 'presentation/home_routes.dart';

final class HomeFeature extends AppFeature {
  const HomeFeature();

  @override
  String get name => 'home';

  @override
  List<AppPageRoute> get routes => const [HomeRoute()];

  @override
  List<AppTabEntry> get tabs => const [_HomeTabEntry()];
}

final class _HomeTabEntry extends AppTabEntry {
  const _HomeTabEntry();

  @override
  String get key => 'home.root';

  @override
  String label(BuildContext context) => context.i18n.homeTitle;

  @override
  String icon(BuildContext context) => context.appAsset.logo;

  @override
  String selectedIcon(BuildContext context) => context.appAsset.logo;

  @override
  AppPageRoute get route => const HomeRoute();
}
