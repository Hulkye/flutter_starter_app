import 'package:flutter/material.dart';

import '../data/asset_data.dart';

abstract class AssetExtension<
  TData extends AssetData,
  TExtension extends AssetExtension<TData, TExtension>
>
    extends ThemeExtension<TExtension> {
  final TData assetData;

  const AssetExtension({required this.assetData});

  @override
  TExtension copyWith({TData? assetData});

  @override
  TExtension lerp(covariant TExtension? other, double t);
}
