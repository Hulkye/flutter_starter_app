// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get homeTitle => 'Home';

  @override
  String get profileTitle => 'Profile';

  @override
  String get goToProfile => 'Go to profile';

  @override
  String get requestDemo => 'Request demo API';

  @override
  String get requesting => 'Requesting...';

  @override
  String get switchThemeMode => 'Switch theme mode';

  @override
  String get currentThemeMode => 'Current theme mode';

  @override
  String get currentLogoAsset => 'Current logo asset';
}
