import 'package:flutter/material.dart';

import 'asset/app_asset.dart';
import 'asset/app_dark_asset.dart';
import 'color/app_color.dart';
import 'color/app_dark_color.dart';
import 'extension/asset_extension.dart';
import 'extension/color_extension.dart';

abstract final class AppThemeData {
  static ThemeData get light {
    final appColor = AppColor();
    final appAsset = AppAsset();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: appColor.brand,
      scaffoldBackgroundColor: appColor.backgroundSecondary,
      splashFactory: NoSplash.splashFactory, //移除水波纹
      highlightColor: Colors.transparent, //移除水波纹
      extensions: <ThemeExtension<dynamic>>[
        ColorExtension(colorData: appColor),
        AssetExtension(assetData: appAsset),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: appColor.backgroundSecondary,
        foregroundColor: appColor.fontPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final appColor = AppDarkColor();
    final appAsset = AppDarkAsset();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: appColor.brand,
      scaffoldBackgroundColor: appColor.backgroundSecondary,
      splashFactory: NoSplash.splashFactory, //移除水波纹
      highlightColor: Colors.transparent, //移除水波纹
      extensions: <ThemeExtension<dynamic>>[
        ColorExtension(colorData: appColor),
        AssetExtension(assetData: appAsset),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: appColor.backgroundSecondary,
        foregroundColor: appColor.fontPrimary,
        elevation: 0,
      ),
    );
  }
}
