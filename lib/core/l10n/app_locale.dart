import 'package:flutter/material.dart';

enum AppLocale { zh, en, system }

extension AppLocaleX on AppLocale {
  String get languageCode {
    switch (this) {
      case AppLocale.zh:
        return 'zh';
      case AppLocale.en:
        return 'en';
      case AppLocale.system:
        return 'system';
    }
  }

  Locale? get locale {
    switch (this) {
      case AppLocale.zh:
        return const Locale('zh', 'CN');
      case AppLocale.en:
        return const Locale('en', 'US');
      case AppLocale.system:
        return null;
    }
  }

  static AppLocale fromCode(String? code) {
    switch (code) {
      case 'zh':
        return AppLocale.zh;
      case 'en':
        return AppLocale.en;
      case 'system':
      default:
        return AppLocale.system;
    }
  }
}
