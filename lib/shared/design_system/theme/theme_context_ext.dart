import 'package:flutter/material.dart';

import 'asset/app_asset.dart';
import 'color/app_color.dart';
import 'extension/asset_extension.dart';
import 'extension/color_extension.dart';

extension ThemeContextExt on BuildContext {
  AppColor get appColor {
    final colorData = Theme.of(this).extension<ColorExtension>()!.colorData;
    return colorData is AppColor ? colorData : AppColor();
  }

  AppAsset get appAsset {
    final assetData = Theme.of(this).extension<AssetExtension>()!.assetData;
    return assetData is AppAsset ? assetData : AppAsset();
  }
}
