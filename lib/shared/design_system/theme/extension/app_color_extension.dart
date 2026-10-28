import 'color_extension.dart';
import '../color/app_color.dart';

final class AppColorExtension
    extends ColorExtension<AppColor, AppColorExtension> {
  const AppColorExtension({required super.colorData});

  @override
  AppColorExtension copyWith({AppColor? colorData}) {
    return AppColorExtension(colorData: colorData ?? this.colorData);
  }

  @override
  AppColorExtension lerp(covariant AppColorExtension? other, double t) {
    if (other == null) return this;
    final interpolated = colorData.lerp(other.colorData, t);
    if (interpolated is! AppColor) return this;
    return AppColorExtension(colorData: interpolated);
  }
}
