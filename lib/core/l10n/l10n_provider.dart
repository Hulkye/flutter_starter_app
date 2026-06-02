import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage.dart';
import 'app_locale.dart';

const String _localeStorageKey = 'app_locale_code';

class AppLocaleNotifier extends Notifier<AppLocale> {
  @override
  AppLocale build() {
    final storedCode = ref.read(prefsStorageProvider).getString(_localeStorageKey);
    return AppLocaleX.fromCode(storedCode);
  }

  void setLocale(AppLocale locale) {
    state = locale;
    unawaited(ref.read(prefsStorageProvider).setString(
      _localeStorageKey,
      locale.languageCode,
    ));
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, AppLocale>(
  AppLocaleNotifier.new,
);

final appLocaleValueProvider = Provider<Locale?>((ref) {
  return ref.watch(appLocaleProvider).locale;
});
