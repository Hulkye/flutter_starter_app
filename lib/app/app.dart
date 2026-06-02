import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/app/env.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';

import '../core/l10n/l10n.dart';
import '../core/l10n/gen/app_localizations.dart';
import '../core/router/router.dart';
import '../core/theme/theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocale = ref.watch(appLocaleValueProvider);
    final themeMode = ref.watch(materialThemeModeProvider);
    Widget child = MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppThemeData.light,
      darkTheme: AppThemeData.dark,
      themeMode: themeMode,
      locale: appLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(goRouterProvider),
    );
    child = ScreenUtil.screenInit(child, appConfig.uiScreenSize);
    return child;
  }
}
