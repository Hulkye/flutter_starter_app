import 'package:flutter_starter_app/header.dart';

class ProfilePage extends BasePage {
  const ProfilePage({super.key});

  AppThemeMode _nextThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.system;
      case AppThemeMode.system:
        return AppThemeMode.light;
    }
  }

  String _themeModeLabel(BuildContext context, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return context.i18n.lightMode;
      case AppThemeMode.dark:
        return context.i18n.darkMode;
      case AppThemeMode.system:
        return context.i18n.systemMode;
    }
  }

  Future<void> _confirmLogout(PageScope scope) {
    return showCommonConfirmSheet(
      scope.context,
      title: scope.context.i18n.logout,
      content: scope.context.i18n.logout,
      onConfirm: () {
        scope.ref.read(authSessionProvider.notifier).clear();
      },
    );
  }

  void _openWebPage(
    PageScope scope, {
    required String url,
    required String title,
  }) {
    if (WebPageConfig.normalizeWebUri(url) == null) {
      PresentationHelper.emitHint(scope.context.i18n.webInvalidUrl);
      return;
    }
    scope.ref
        .read(appRouterProvider)
        .push(WebPageRoute(url: url, title: title).location);
  }

  // ── AppBar ──

  @override
  PreferredSizeWidget? appBar(PageScope scope) {
    return AppBar(title: Text(scope.context.i18n.profileTitle));
  }

  // ── 页面 ──

  @override
  Widget page(PageScope scope) {
    final context = scope.context;
    final ref = scope.ref;
    final appColor = context.appColor;
    final themeMode = ref.watch(appThemeModeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: appColor.compBackgroundPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appColor.compDivider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.i18n.profileTitle,
                    style: TextStyle(
                      color: appColor.fontPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.i18n.currentThemeMode}: ${_themeModeLabel(context, themeMode)}',
                    style: TextStyle(color: appColor.fontSecondary),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.brightness_6_outlined),
                      title: Text(context.i18n.switchThemeMode),
                      subtitle: Text(_themeModeLabel(context, themeMode)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ref
                            .read(appThemeModeProvider.notifier)
                            .setThemeMode(_nextThemeMode(themeMode));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: appColor.compBackgroundPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appColor.compDivider),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(context.i18n.privacyPolicy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _openWebPage(
                        scope,
                        url: appConfig.privacyPolicyUrl,
                        title: context.i18n.privacyPolicy,
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 56,
                    color: appColor.compDivider,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(context.i18n.serviceAgreement),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _openWebPage(
                        scope,
                        url: appConfig.userAgreementUrl,
                        title: context.i18n.serviceAgreement,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryRoundButton(
            context: context,
            label: context.i18n.logout,
            onPressed: () => _confirmLogout(scope),
            expand: true,
          ),
        ],
      ),
    );
  }
}
