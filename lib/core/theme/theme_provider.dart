import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage.dart';
import 'app_theme_mode.dart';

const String _themeModeKey = 'app_theme_mode';

class AppThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    final storedValue = ref.read(prefsStorageProvider).getInt(_themeModeKey);
    return AppThemeModeX.fromStorageValue(storedValue);
  }

  void setThemeMode(AppThemeMode mode) {
    state = mode;
    unawaited(
      ref.read(prefsStorageProvider).setInt(_themeModeKey, mode.storageValue),
    );
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, AppThemeMode>(
      AppThemeModeNotifier.new,
    );

final materialThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appThemeModeProvider).toThemeMode;
});
