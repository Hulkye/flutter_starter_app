import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../generated/app_localizations.dart';

final sharedLocalizationLocaleProvider = Provider<Locale?>((ref) => null);

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(sharedLocalizationLocaleProvider);
  final preferredLocales = locale == null
      ? ui.PlatformDispatcher.instance.locales
      : [locale];
  return lookupAppLocalizations(
    basicLocaleListResolution(
      preferredLocales,
      AppLocalizations.supportedLocales,
    ),
  );
}, dependencies: [sharedLocalizationLocaleProvider]);
