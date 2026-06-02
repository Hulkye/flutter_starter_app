import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

extension AppThemeModeX on AppThemeMode {
  int get storageValue {
    switch (this) {
      case AppThemeMode.light:
        return 0;
      case AppThemeMode.dark:
        return 1;
      case AppThemeMode.system:
        return 2;
    }
  }

  ThemeMode get toThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromStorageValue(int? value) {
    switch (value) {
      case 0:
        return AppThemeMode.light;
      case 1:
        return AppThemeMode.dark;
      case 2:
      default:
        return AppThemeMode.system;
    }
  }
}
