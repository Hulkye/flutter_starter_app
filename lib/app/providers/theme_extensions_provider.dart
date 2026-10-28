import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/feature/app_theme_contribution.dart';

final appLightThemeExtensionsProvider = Provider<List<AppThemeContribution>>(
  (ref) => const [],
);

final appDarkThemeExtensionsProvider = Provider<List<AppThemeContribution>>(
  (ref) => const [],
);
