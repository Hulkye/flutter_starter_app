import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/feature/app_theme_contribution.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

import 'preferences/locale_preference.dart';
import 'preferences/theme_preference.dart';
import 'providers/theme_extensions_provider.dart';
import 'providers/localization_delegates_provider.dart';
import '../core/router/export.dart';
import '../shared/design_system/design_system.dart';
import '../shared/localization/localization.dart';
import 'host/app_host.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocale = ref.watch(appLocaleValueProvider);
    final themeMode = ref.watch(materialThemeModeProvider);
    final lightThemeExtensions = ref.watch(appLightThemeExtensionsProvider);
    final darkThemeExtensions = ref.watch(appDarkThemeExtensionsProvider);
    final featureLocalizationDelegates = ref.watch(
      appLocalizationDelegatesProvider,
    );
    return ProviderScope(
      overrides: [
        sharedLocalizationLocaleProvider.overrideWith((ref) {
          return ref.watch(appLocaleValueProvider);
        }),
      ],
      child: _buildApp(
        context,
        ref,
        appLocale,
        themeMode,
        lightThemeExtensions,
        darkThemeExtensions,
        featureLocalizationDelegates,
      ),
    );
  }

  Widget _buildApp(
    BuildContext context,
    WidgetRef ref,
    Locale? appLocale,
    ThemeMode themeMode,
    List<AppThemeContribution> lightThemeExtensions,
    List<AppThemeContribution> darkThemeExtensions,
    List<LocalizationsDelegate<dynamic>> featureLocalizationDelegates,
  ) {
    Widget child = MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppThemeData.buildLight(extensions: lightThemeExtensions),
      darkTheme: AppThemeData.buildDark(extensions: darkThemeExtensions),
      themeMode: themeMode,
      locale: appLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...featureLocalizationDelegates,
      ],
      routerConfig: ref.watch(routerConfigProvider),
      builder: (BuildContext context, Widget? child) {
        return ToastUtil.initBuilder(context, child);
      },
    );
    child = AppHost(child: child);
    child = ScreenUtil.screenInit(child, appConfig.uiScreenSize);
    return child;
  }
}
