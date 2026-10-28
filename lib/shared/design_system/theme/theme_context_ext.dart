import 'package:flutter/material.dart';

import 'asset/app_asset.dart';
import 'color/app_color.dart';
import 'extension/app_asset_extension.dart';
import 'extension/app_color_extension.dart';

extension ThemeContextExt on BuildContext {
  AppColor get appColor {
    final extension = Theme.of(this).extension<AppColorExtension>();
    return extension?.colorData ?? AppColor();
  }

  AppAsset get appAsset {
    final extension = Theme.of(this).extension<AppAssetExtension>();
    return extension?.assetData ?? AppAsset();
  }
}
