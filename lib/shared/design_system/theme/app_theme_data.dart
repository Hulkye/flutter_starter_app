import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset/app_asset.dart';
import 'asset/app_dark_asset.dart';
import 'color/app_color.dart';
import 'color/app_dark_color.dart';
import 'extension/app_asset_extension.dart';
import 'extension/app_color_extension.dart';
import '../../../core/feature/app_theme_contribution.dart';

abstract final class AppThemeData {
  static ThemeData get light => buildLight();

  static ThemeData buildLight({
    Iterable<AppThemeContribution> extensions = const [],
  }) {
    final appColor = AppColor();
    final appAsset = AppAsset();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appColor.brand,
      scaffoldBackgroundColor: appColor.backgroundSecondary,
      splashFactory: NoSplash.splashFactory, //移除水波纹
      highlightColor: Colors.transparent, //移除水波纹
      extensions: _themeExtensions(
        extensions,
        AppColorExtension(colorData: appColor),
        AppAssetExtension(assetData: appAsset),
        brightness: 'light',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appColor.backgroundSecondary,
        foregroundColor: appColor.fontPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  static ThemeData get dark => buildDark();

  static ThemeData buildDark({
    Iterable<AppThemeContribution> extensions = const [],
  }) {
    final appColor = AppDarkColor();
    final appAsset = AppDarkAsset();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appColor.brand,
      scaffoldBackgroundColor: appColor.backgroundSecondary,
      splashFactory: NoSplash.splashFactory, //移除水波纹
      highlightColor: Colors.transparent, //移除水波纹
      extensions: _themeExtensions(
        extensions,
        AppColorExtension(colorData: appColor),
        AppAssetExtension(assetData: appAsset),
        brightness: 'dark',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appColor.backgroundSecondary,
        foregroundColor: appColor.fontPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  static Iterable<ThemeExtension<dynamic>> _themeExtensions(
    Iterable<AppThemeContribution> contributions,
    AppColorExtension appColor,
    AppAssetExtension appAsset, {
    required String brightness,
  }) sync* {
    final owners = <Type, String>{
      appColor.runtimeType: 'App',
      appAsset.runtimeType: 'App',
    };
    for (final contribution in contributions) {
      final value = contribution.value;
      if (value is! ThemeExtension<dynamic>) {
        throw ArgumentError.value(
          value,
          'contribution',
          'Feature theme contributions must extend ThemeExtension.',
        );
      }
      final previousOwner = owners[value.runtimeType];
      if (previousOwner != null) {
        throw StateError(
          '$brightness theme extension conflict '
          '"${value.runtimeType}": '
          '$previousOwner and ${contribution.featureKey}',
        );
      }
      owners[value.runtimeType] = contribution.featureKey;
    }
    yield appColor;
    yield appAsset;
    for (final contribution in contributions) {
      yield contribution.value as ThemeExtension<dynamic>;
    }
  }
}
