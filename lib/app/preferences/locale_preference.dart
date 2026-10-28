import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import '../../core/storage/storage.dart';
import '../../shared/localization/localization.dart';

enum AppLocale { zh, en, system }

extension AppLocaleX on AppLocale {
  String get languageCode => switch (this) {
    AppLocale.zh => 'zh',
    AppLocale.en => 'en',
    AppLocale.system => 'system',
  };

  Locale? get locale => switch (this) {
    AppLocale.zh => const Locale('zh', 'CN'),
    AppLocale.en => const Locale('en', 'US'),
    AppLocale.system => null,
  };

  static AppLocale fromCode(String? code) => switch (code) {
    'zh' => AppLocale.zh,
    'en' => AppLocale.en,
    _ => AppLocale.system,
  };
}

Locale resolveAppLocale(
  AppLocale preference,
  List<Locale> systemLocales,
  List<Locale> supportedLocales,
) {
  final preferredLocale = preference.locale;
  return basicLocaleListResolution(
    preferredLocale == null ? systemLocales : [preferredLocale],
    supportedLocales,
  );
}

const String _localeStorageKey = 'app_locale_code';

class AppLocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() {
    final storedCode = ref
        .read(prefsStorageProvider)
        .getString(_localeStorageKey);
    return AppLocaleX.fromCode(storedCode);
  }

  void setLocale(AppLocale locale) {
    state = locale;
    unawaited(
      ref
          .read(prefsStorageProvider)
          .setString(_localeStorageKey, locale.languageCode),
    );
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, AppLocale>(
  AppLocaleNotifier.new,
);

final appLocaleValueProvider = Provider<Locale?>((ref) {
  final preference = ref.watch(appLocaleProvider);
  if (preference == AppLocale.system) return null;
  return resolveAppLocale(
    preference,
    ui.PlatformDispatcher.instance.locales,
    AppLocalizations.supportedLocales,
  );
});
