import 'package:flutter/material.dart';

import '../data/asset_data.dart';

class AssetExtension extends ThemeExtension<AssetExtension> {
  final AssetData assetData;

  const AssetExtension({required this.assetData});

  @override
  AssetExtension copyWith({AssetData? assets}) {
    return AssetExtension(assetData: assets ?? assetData);
  }

  @override
  AssetExtension lerp(ThemeExtension<AssetExtension>? other, double t) {
    if (other is! AssetExtension) return this;
    return this; // 图片资源通常不需要插值
  }
}
