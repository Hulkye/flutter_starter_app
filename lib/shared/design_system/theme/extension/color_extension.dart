import 'package:flutter/material.dart';

import '../data/color_data.dart';

abstract class ColorExtension<
  TData extends ColorData,
  TExtension extends ColorExtension<TData, TExtension>
>
    extends ThemeExtension<TExtension> {
  final TData colorData;

  const ColorExtension({required this.colorData});

  @override
  TExtension copyWith({TData? colorData});

  @override
  TExtension lerp(covariant TExtension? other, double t);
}
