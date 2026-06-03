import 'package:flutter_starter_app/core/l10n/app_locale.dart';
import 'package:flutter_starter_app/core/l10n/l10n_provider.dart';
import 'package:flutter_starter_app/core/storage/storage_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/provider_container.dart';

void main() {
  group('AppLocaleNotifier', () {
    test('restores stored locale from prefs storage', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'zh'});
      await prefsStorage.init();
      final container = createTestContainer();

      expect(container.read(appLocaleProvider), AppLocale.zh);
      expect(container.read(appLocaleValueProvider)?.languageCode, 'zh');
    });

    test('persists locale changes', () async {
      SharedPreferences.setMockInitialValues({});
      await prefsStorage.init();
      final container = createTestContainer();

      container.read(appLocaleProvider.notifier).setLocale(AppLocale.en);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(appLocaleProvider), AppLocale.en);
      expect(prefsStorage.getString('app_locale_code'), 'en');
    });
  });
}
