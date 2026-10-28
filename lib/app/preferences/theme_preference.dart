import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/storage.dart';

enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  int get storageValue => switch (this) {
    AppThemeMode.light => 0,
    AppThemeMode.dark => 1,
    AppThemeMode.system => 2,
  };

  ThemeMode get toThemeMode => switch (this) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };

  static AppThemeMode fromStorageValue(int? value) => switch (value) {
    0 => AppThemeMode.light,
    1 => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };
}

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
