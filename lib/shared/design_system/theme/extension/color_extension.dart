import 'package:flutter/material.dart';

import '../data/color_data.dart';

class ColorExtension extends ThemeExtension<ColorExtension> {
  final ColorData colorData;

  const ColorExtension({required this.colorData});

  @override
  ColorExtension copyWith({ColorData? colors}) {
    return ColorExtension(colorData: colors ?? colorData);
  }

  @override
  ColorExtension lerp(ThemeExtension<ColorExtension>? other, double t) {
    if (other is! ColorExtension) return this;
    ColorData newColorData = colorData.lerp(other.colorData, t);
    return ColorExtension(colorData: newColorData);
  }
}
