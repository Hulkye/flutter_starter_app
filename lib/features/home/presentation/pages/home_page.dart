import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/presentation/presentation.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../profile/presentation/profile_routes.dart';

class HomePage extends BasePage<HomeViewModel> {
  const HomePage({super.key});

  // ── VM 接入 ──

  @override
  HomeViewModel notifier(WidgetRef ref) =>
      ref.read(homeViewModelProvider.notifier);

  @override
  BaseState watchState(WidgetRef ref) => ref.watch(homeViewModelProvider);

  // ── AppBar ──

  @override
  PreferredSizeWidget? appBar(
    BuildContext context,
    WidgetRef ref,
    HomeViewModel vm,
  ) {
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
  Widget page(BuildContext context, WidgetRef ref, HomeViewModel vm) {
    final themeMode = ref.watch(appThemeModeProvider);
    final homeState = ref.watch(homeViewModelProvider);
    final appColors = context.appColor;
    final appAssets = context.appAsset;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${context.i18n.currentThemeMode}: $themeMode',
            style: TextStyle(color: appColors.textPrimary),
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
                  color: appColors.textSecondary,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${context.i18n.currentLogoAsset}: ${appAssets.logo}',
            style: TextStyle(color: appColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(appRouterProvider).push(const ProfileRoute());
            },
            child: Text(context.i18n.goToProfile),
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
              style: TextStyle(color: appColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
