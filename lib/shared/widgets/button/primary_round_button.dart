import 'package:flutter_starter_app/core/theme/theme_context_ext.dart';
import 'package:flutter_starter_app/core/util/screen_util.dart';

import 'round_button.dart';

///主题颜色提交按钮
Widget createSubmitRoundButton({
  required BuildContext context,
  required String label,
  VoidCallback? onPressed,
}) {
  return PrimaryRoundButton(
    context: context,
    label: label,
    height: 53.w,
    onPressed: onPressed,
    expand: false,
  );
}

/// 主要按钮
/// 常用于confirm按钮
class PrimaryRoundButton extends RoundButton {
  PrimaryRoundButton({
    required BuildContext context,
    required super.label,
    double? height,
    super.width,
    double? fontSize,
    super.fontWeight,
    double? lineHeight,
    super.borderRadius,
    super.onPressed,
    super.onLongPress,
    super.prefixWidget,
    super.suffixWidget,
    super.key,
    super.padding,
    super.expand,
    super.overflow,
    super.maxLines,
    Color? textColor,
    Color? bgColor,
    TextStyle Function(TextStyle style)? textStyleBuilder,
  }) : super(
         height: height ?? 53.w,
         fontSize: fontSize ?? 17.sp,
         lineHeight: lineHeight ?? 1.4,
         textColor: textColor ?? context.appColor.fontOnPrimary,
         textColorDisabled: context.appColor.fontTertiary,
         bgColor: bgColor ?? context.appColor.brand,
         bgColorDisabled: context.appColor.compBackgroundSecondary,
         bgColorHighlight: context.appColor.interactivePressed,
       );
}
