import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/presentation/presentation.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../profile/presentation/profile_routes.dart';
import '../../../todo/presentation/todo_routes.dart';

class HomePage extends BasePage {
  const HomePage({super.key});

  // ── AppBar ──

  @override
  PreferredSizeWidget? appBar(PageScope scope) {
    final context = scope.context;
    final ref = scope.ref;

    return AppBar(
      title: Text(context.i18n.homeTitle),
      actions: [
        IconButton(
          onPressed: () {
            ref
                .read(appThemeModeProvider.notifier)
                .setThemeMode(
                  ref.read(appThemeModeProvider) == AppThemeMode.light
                      ? AppThemeMode.dark
                      : AppThemeMode.light,
                );
          },
          tooltip: context.i18n.switchThemeMode,
          icon: const Icon(Icons.brightness_6_outlined),
        ),
      ],
    );
  }

  // ── 页面 ──

  @override
  Widget page(PageScope scope) {
    final context = scope.context;
    final ref = scope.ref;
    final vm = ref.read(homeViewModelProvider.notifier);
    final homeState = ref.watch(homeViewModelProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final appColors = context.appColor;
    final appAssets = context.appAsset;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${context.i18n.currentThemeMode}: $themeMode',
            style: TextStyle(color: appColors.fontPrimary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              appAssets.logo,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: appColors.fontSecondary,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${context.i18n.currentLogoAsset}: ${appAssets.logo}',
            style: TextStyle(color: appColors.fontSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(appRouterProvider).push(const ProfileRoute().location);
            },
            child: Text(context.i18n.goToProfile),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(appRouterProvider).push(const TodoRoute().location);
            },
            child: Text(context.i18n.goToTodo),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: homeState.requesting
                ? null
                : () {
                    vm.requestDemo();
                  },
            child: Text(
              homeState.requesting
                  ? context.i18n.requesting
                  : context.i18n.requestDemo,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 320,
            child: Text(
              homeState.requestResult,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: appColors.fontSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
