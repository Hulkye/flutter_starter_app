import 'package:flutter/material.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_starter_app/core/theme/app_theme_mode.dart';
import 'package:flutter_starter_app/core/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/provider_container.dart';

void main() {
  group('AppThemeModeNotifier', () {
    test('restores stored theme mode from prefs storage', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 1});
      await prefsStorage.init();
      final container = createTestContainer();

      expect(container.read(appThemeModeProvider), AppThemeMode.dark);
      expect(container.read(materialThemeModeProvider), ThemeMode.dark);
    });

    test('persists theme mode changes', () async {
      SharedPreferences.setMockInitialValues({});
      await prefsStorage.init();
      final container = createTestContainer();

      container
          .read(appThemeModeProvider.notifier)
          .setThemeMode(AppThemeMode.light);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(appThemeModeProvider), AppThemeMode.light);
      expect(prefsStorage.getInt('app_theme_mode'), 0);
    });
  });
}
