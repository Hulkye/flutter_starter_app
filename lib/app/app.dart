import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/config/env_config.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';
import 'package:flutter_starter_app/shared/widgets/toast/toast_util.dart';

import 'preferences/locale_preference.dart';
import 'preferences/theme_preference.dart';
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
    return ProviderScope(
      overrides: [
        sharedLocalizationLocaleProvider.overrideWith((ref) {
          return ref.watch(appLocaleValueProvider);
        }),
      ],
      child: _buildApp(context, ref, appLocale, themeMode),
    );
  }

  Widget _buildApp(
    BuildContext context,
    WidgetRef ref,
    Locale? appLocale,
    ThemeMode themeMode,
  ) {
    Widget child = MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      themeMode: themeMode,
      locale: appLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
